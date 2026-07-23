# 이벤트 발생 전후 프레임을 모아 mp4 클립으로 저장하는 파일입니다.
# 프레임 버퍼 관리와 클립 파일 생성 흐름이 포함되어 있습니다.

from __future__ import annotations

import hashlib
import re
from collections import deque
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from threading import RLock

import cv2
import numpy as np

from app.config import SERVER_CLIP_DIR, SERVER_EVENT_THUMBNAIL_DIR


@dataclass(frozen=True)
class _BufferedFrame:
    captured_at: datetime
    jpeg_bytes: bytes


class ServerClipRecorder:
    def __init__(
        self,
        *,
        clip_dir: Path,
        buffer_seconds: float = 45.0,
        before_seconds: float = 3.0,
        after_seconds: float = 1.0,
        fallback_fps: float = 10.0,
    ) -> None:
        self.clip_dir = clip_dir
        self.buffer_seconds = max(5.0, buffer_seconds)
        self.before_seconds = max(0.0, before_seconds)
        self.after_seconds = max(0.0, after_seconds)
        self.fallback_fps = max(1.0, fallback_fps)
        self._frames_by_source_key: dict[str, deque[_BufferedFrame]] = {}
        self._lock = RLock()

    def add_frame(
        self,
        *,
        source_key: str,
        jpeg_bytes: bytes,
        captured_at: datetime | None = None,
    ) -> None:
        normalized_source_key = source_key.strip()
        if not normalized_source_key or not jpeg_bytes:
            return
        frame = _BufferedFrame(
            captured_at=captured_at or datetime.now(),
            jpeg_bytes=bytes(jpeg_bytes),
        )
        cutoff = frame.captured_at - timedelta(seconds=self.buffer_seconds)
        with self._lock:
            frames = self._frames_by_source_key.setdefault(
                normalized_source_key,
                deque(),
            )
            frames.append(frame)
            while frames and frames[0].captured_at < cutoff:
                frames.popleft()

    def encode_event_clip(
        self,
        *,
        source_key: str,
        source_slug: str,
        event_key: str,
        started_at: datetime,
        ended_at: datetime,
    ) -> dict[str, object] | None:
        normalized_source_key = source_key.strip()
        if not normalized_source_key:
            return None

        start_window = started_at - timedelta(seconds=self.before_seconds)
        end_window = ended_at + timedelta(seconds=self.after_seconds)
        with self._lock:
            buffered = list(self._frames_by_source_key.get(normalized_source_key, ()))

        selected = [
            frame
            for frame in buffered
            if start_window <= frame.captured_at <= end_window
        ]
        if not selected:
            return None

        decoded_frames = [_decode_jpeg(frame.jpeg_bytes) for frame in selected]
        decoded_frames = [frame for frame in decoded_frames if frame is not None]
        if not decoded_frames:
            return None

        self.clip_dir.mkdir(parents=True, exist_ok=True)
        clip_name = self._build_clip_name(
            source_key=normalized_source_key,
            source_slug=source_slug,
            event_key=event_key,
            ended_at=ended_at,
        )
        clip_path = (self.clip_dir / clip_name).resolve()
        thumbnail_name = f"{Path(clip_name).stem}.jpg"
        thumbnail_path = (SERVER_EVENT_THUMBNAIL_DIR / thumbnail_name).resolve()

        height, width = decoded_frames[0].shape[:2]
        fps = self._estimate_fps(selected)
        writer = cv2.VideoWriter(
            str(clip_path),
            cv2.VideoWriter_fourcc(*"mp4v"),
            fps,
            (width, height),
        )
        if not writer.isOpened():
            return None
        try:
            for frame in decoded_frames:
                next_frame = frame
                if frame.shape[1] != width or frame.shape[0] != height:
                    next_frame = cv2.resize(frame, (width, height))
                writer.write(next_frame)
        finally:
            writer.release()

        if not clip_path.exists() or clip_path.stat().st_size <= 0:
            clip_path.unlink(missing_ok=True)
            return None

        try:
            SERVER_EVENT_THUMBNAIL_DIR.mkdir(parents=True, exist_ok=True)
            thumbnail_path.write_bytes(selected[0].jpeg_bytes)
        except OSError:
            thumbnail_name = ""

        return {
            "clip_path": str(clip_path),
            "clip_url": f"/api/clips/{clip_name}",
            "server_clip_name": clip_name,
            "server_clip_path": f"clips/{clip_name}",
            "thumbnail_url": f"/api/event-thumbnails/{thumbnail_name}" if thumbnail_name else "",
            "thumbnail_name": thumbnail_name,
            "clip_available": True,
            "clip_upload_ok": True,
            "preferred_clip_source": "server",
        }

    def clear_all(self) -> None:
        with self._lock:
            self._frames_by_source_key.clear()
    def clear_source(self, source_key: str) -> None:
        normalized_source_key = source_key.strip()
        if not normalized_source_key:
            return
        with self._lock:
            self._frames_by_source_key.pop(normalized_source_key, None)

    def _estimate_fps(self, frames: list[_BufferedFrame]) -> float:
        if len(frames) < 2:
            return self.fallback_fps
        duration_seconds = max(
            0.001,
            (frames[-1].captured_at - frames[0].captured_at).total_seconds(),
        )
        fps = (len(frames) - 1) / duration_seconds
        return max(1.0, min(30.0, fps or self.fallback_fps))

    def _build_clip_name(
        self,
        *,
        source_key: str,
        source_slug: str,
        event_key: str,
        ended_at: datetime,
    ) -> str:
        slug = _sanitize_slug(source_slug) or hashlib.sha1(
            source_key.encode("utf-8")
        ).hexdigest()[:12]
        event_digest = hashlib.sha1(event_key.encode("utf-8")).hexdigest()[:10]
        timestamp = ended_at.strftime("%Y%m%d_%H%M%S_%f")
        return f"{slug}__server_event__{timestamp}__{event_digest}.mp4"


def _decode_jpeg(jpeg_bytes: bytes):
    image_array = np.frombuffer(jpeg_bytes, dtype=np.uint8)
    frame = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
    return frame


def _sanitize_slug(value: str) -> str:
    normalized = value.strip().lower()
    normalized = re.sub(r"[^a-z0-9_.-]+", "_", normalized)
    normalized = normalized.strip("._-")
    return normalized[:80]


server_clip_recorder = ServerClipRecorder(clip_dir=SERVER_CLIP_DIR)

