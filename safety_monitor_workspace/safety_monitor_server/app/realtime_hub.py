# WebSocket으로 화면에 실시간 갱신 알림을 보내는 허브 파일입니다.
# 이벤트나 소스 상태 변경 신호를 연결된 클라이언트들에게 전달합니다.

from __future__ import annotations

import asyncio
import json
import threading
from time import monotonic
from typing import Any

from fastapi import WebSocket
from fastapi import WebSocketDisconnect

from app.log_utils import log_line


class RealtimeUpdateHub:
    def __init__(self) -> None:
        self._lock = threading.RLock()
        self._listeners: dict[int, tuple[asyncio.AbstractEventLoop, asyncio.Queue[str]]] = {}
        self._summary_counts: dict[str, int] = {}
        self._summary_last_flush = monotonic()
        self._summary_interval_seconds = 5.0

    async def serve(self, websocket: WebSocket) -> None:
        await websocket.accept()
        queue: asyncio.Queue[str] = asyncio.Queue(maxsize=128)
        listener_id = id(queue)
        loop = asyncio.get_running_loop()
        with self._lock:
            self._listeners[listener_id] = (loop, queue)
            listener_count = len(self._listeners)
        log_line("PUSH", event="client-connect", clients=listener_count)
        try:
            while True:
                payload = await queue.get()
                await websocket.send_text(payload)
        except WebSocketDisconnect:
            pass
        finally:
            with self._lock:
                self._listeners.pop(listener_id, None)
                listener_count = len(self._listeners)
            log_line("PUSH", event="client-disconnect", clients=listener_count)

    def publish(self, message_type: str, **payload: Any) -> None:
        message = {"type": message_type, **payload}
        encoded = json.dumps(message, ensure_ascii=False)
        with self._lock:
            listeners = list(self._listeners.items())
            listener_count = len(listeners)
        if listener_count <= 0:
            return
        self._log_publish(
            message_type=message_type,
            listener_count=listener_count,
            payload=payload,
        )
        stale_listener_ids: list[int] = []
        for listener_id, (loop, queue) in listeners:
            try:
                loop.call_soon_threadsafe(self._enqueue_message, queue, encoded)
            except RuntimeError:
                stale_listener_ids.append(listener_id)

        if stale_listener_ids:
            with self._lock:
                for listener_id in stale_listener_ids:
                    self._listeners.pop(listener_id, None)

    def _log_publish(
        self,
        *,
        message_type: str,
        listener_count: int,
        payload: dict[str, Any],
    ) -> None:
        if message_type == "source_status_changed":
            self._record_publish_summary(
                message_type=message_type,
                listener_count=listener_count,
            )
            return

        self._flush_publish_summary(force=False, listener_count=listener_count)
        log_line(
            "PUSH",
            event=message_type,
            clients=listener_count,
            source=str(payload.get("source_key", "")).strip() or None,
            action=str(payload.get("action", "")).strip() or None,
            state=str(payload.get("state", "")).strip() or None,
        )

    def _record_publish_summary(
        self,
        *,
        message_type: str,
        listener_count: int,
    ) -> None:
        with self._lock:
            self._summary_counts[message_type] = self._summary_counts.get(message_type, 0) + 1
        self._flush_publish_summary(force=False, listener_count=listener_count)

    def _flush_publish_summary(self, *, force: bool, listener_count: int) -> None:
        now = monotonic()
        with self._lock:
            elapsed = now - self._summary_last_flush
            if not force and elapsed < self._summary_interval_seconds:
                return
            summary_counts = dict(self._summary_counts)
            self._summary_counts.clear()
            self._summary_last_flush = now
        for message_type, count in summary_counts.items():
            if count <= 0:
                continue
            log_line(
                "PUSH-SUM",
                event=message_type,
                count=count,
                clients=listener_count,
                window=f"{elapsed:.1f}s",
            )

    @staticmethod
    def _enqueue_message(queue: asyncio.Queue[str], payload: str) -> None:
        if queue.full():
            try:
                queue.get_nowait()
            except asyncio.QueueEmpty:
                pass
        try:
            queue.put_nowait(payload)
        except asyncio.QueueFull:
            pass


realtime_update_hub = RealtimeUpdateHub()
