# 카메라 소스별 분석 worker를 시작하고 중지하는 관리자 파일입니다.
# 소스 실행 상태와 서버 presence 동기화 흐름이 포함되어 있습니다.

from __future__ import annotations

import threading
import time
import socket
import json
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

from app.analysis_runtime import build_pipeline_for_source, build_source_record, resolve_source
from app.config import (
    CLIENT_CLIP_DIR,
    CLIENT_SETTINGS_PATH,
    CLIENT_SOURCE_CACHE_DIR,
    CLIENT_UPLOAD_SOURCE_DIR,
    DATABASE_PATH,
)
from app.database import (
    delete_source_status,
    delete_source,
    get_source_status,
    get_source,
    list_source_statuses,
    list_sources,
    prune_orphan_source_data,
    reset_source_data,
    set_source_desired_running,
    upsert_source,
    upsert_source_status,
)
from app.log_utils import log_line
from app.reporting_api import remote_server_reporter
from app.source_rule_config import normalize_rule_config


@dataclass
class _ManagedWorker:
    source_record: dict[str, Any]
    stop_event: threading.Event
    thread: threading.Thread
    stop_reason: str = ""


class AnalysisSourceManager:
    _server_presence_interval_seconds = 5.0

    def __init__(self) -> None:
        self._lock = threading.RLock()
        self._workers: dict[str, _ManagedWorker] = {}
        self._server_presence_stop = threading.Event()
        self._server_presence_thread: threading.Thread | None = None

    def bootstrap(self) -> None:
        self._remove_stale_local_camera_sources()
        for source_record in list_sources(DATABASE_PATH):
            source_key = str(source_record.get("source_key", "")).strip()
            if not source_key:
                continue
            source_type = str(source_record.get("source_type", "")).strip().lower()
            source_value = str(source_record.get("source_value", "")).strip()
            if source_type != "camera" or source_value != "0":
                set_source_desired_running(
                    DATABASE_PATH,
                    source_key=source_key,
                    desired_running=False,
                )
                continue
            if "owner=" not in source_key:
                migrated = build_source_record(
                    source_type="camera",
                    source_value="0",
                    original_source_type=str(
                        source_record.get("original_source_type", "camera")
                    ).strip()
                    or "camera",
                    original_source_value=str(
                        source_record.get("original_source_value", "0")
                    ).strip()
                    or "0",
                    client_id=str(source_record.get("client_id", "")).strip()
                    or _build_default_client_id(),
                    session_id=str(source_record.get("session_id", "")).strip(),
                    desired_running=bool(source_record.get("desired_running", False)),
                )
                migrated["rule_config"] = normalize_rule_config(
                    source_record.get("rule_config")
                )
                upsert_source(DATABASE_PATH, migrated)
                delete_source(DATABASE_PATH, source_key)
                delete_source_status(DATABASE_PATH, source_key)
                remote_server_reporter.delete_source(source_key, clear_data=False)
                source_record = migrated
                source_key = str(source_record.get("source_key", "")).strip()
            latest_source = get_source(DATABASE_PATH, source_key) or source_record
            self._sync_source_to_server(latest_source)
            set_source_desired_running(
                DATABASE_PATH,
                source_key=source_key,
                desired_running=False,
            )
            latest_source = get_source(DATABASE_PATH, source_key) or latest_source
            self._sync_source_to_server(latest_source)
            previous_status = get_source_status(DATABASE_PATH, source_key) or {}
            self._upsert_status_and_sync(
                {
                    "source_key": source_key,
                    "source_type": latest_source["source_type"],
                    "source_value": latest_source["source_value"],
                    "client_id": latest_source["client_id"],
                    "session_id": latest_source["session_id"],
                    "state": "registered",
                    "is_running": False,
                    "source_fps": float(previous_status.get("source_fps", 0.0) or 0.0),
                    "last_frame_id": int(previous_status.get("last_frame_id", -1) or -1),
                    "last_source_time_seconds": float(
                        previous_status.get("last_source_time_seconds", 0.0) or 0.0
                    ),
                    "error_message": "",
                }
            )
            log_line(
                "SRC",
                action="bootstrap-defer-camera",
                source=source_key,
            )
            continue
        self._start_server_presence_loop()

    def shutdown(self) -> None:
        self._server_presence_stop.set()
        if self._server_presence_thread is not None:
            self._server_presence_thread.join(timeout=2.0)
        with self._lock:
            worker_keys = list(self._workers.keys())
        for source_key in worker_keys:
            self.stop_source(
                source_key,
                update_desired_running=False,
                stop_reason="shutdown",
            )

    def register_source(
        self,
        *,
        source_type: str,
        source_value: str,
        client_id: str = "",
        session_id: str = "",
        reset_existing: bool = True,
        start_immediately: bool = True,
    ) -> dict[str, Any]:
        source_type = "camera"
        source_value = "0"
        client_id = client_id.strip() or _build_default_client_id()
        resolved = resolve_source(source_type=source_type, source_value=source_value)
        source_record = build_source_record(
            source_type=resolved["source_type"],
            source_value=resolved["source_value"],
            original_source_type=resolved["original_source_type"],
            original_source_value=resolved["original_source_value"],
            client_id=client_id,
            session_id=session_id,
            desired_running=start_immediately,
        )
        source_key = str(source_record.get("source_key", "")).strip()
        source_slug = str(source_record.get("source_slug", "")).strip()
        self._remove_stale_local_camera_sources(keep_source_key=source_key)
        existing_source = get_source(DATABASE_PATH, source_key)
        if existing_source is not None:
            source_record["rule_config"] = normalize_rule_config(
                existing_source.get("rule_config")
            )

        upsert_source(DATABASE_PATH, source_record)
        self._sync_source_to_server(source_record)
        if reset_existing:
            reset_source_data(
                DATABASE_PATH,
                source_key=source_key,
                source_slug=source_slug,
                server_clip_dir=CLIENT_CLIP_DIR,
            )
            self._reset_remote_source_data(source_record)

        if start_immediately:
            self.start_source(source_key)
        else:
            previous_status = get_source_status(DATABASE_PATH, source_key) or {}
            self._upsert_status_and_sync(
                {
                    "source_key": source_key,
                    "source_type": source_record["source_type"],
                    "source_value": source_record["source_value"],
                    "client_id": source_record["client_id"],
                    "session_id": source_record["session_id"],
                    "state": "registered",
                    "is_running": False,
                    "source_fps": float(previous_status.get("source_fps", 0.0) or 0.0),
                    "last_frame_id": int(previous_status.get("last_frame_id", -1) or -1),
                    "last_source_time_seconds": float(
                        previous_status.get("last_source_time_seconds", 0.0) or 0.0
                    ),
                    "error_message": "",
                }
            )
            latest = get_source(DATABASE_PATH, source_key) or source_record
            self._sync_source_to_server(latest)
        return get_source(DATABASE_PATH, source_key) or source_record

    def update_source_rule_config(
        self,
        source_key: str,
        *,
        rule_config: dict,
    ) -> dict[str, Any]:
        normalized_source_key = source_key.strip()
        source_record = get_source(DATABASE_PATH, normalized_source_key)
        if source_record is None:
            raise KeyError(normalized_source_key)

        source_type = str(source_record.get("source_type", "")).strip().lower()
        source_record["rule_config"] = normalize_rule_config(rule_config)
        source_record["updated_at"] = datetime.now().isoformat()

        should_reanalyze_from_start = source_type == "video"
        if should_reanalyze_from_start:
            source_record["desired_running"] = True

        upsert_source(DATABASE_PATH, source_record)
        self._sync_source_to_server(source_record)

        if should_reanalyze_from_start:
            self.stop_source(
                normalized_source_key,
                update_desired_running=False,
                stop_reason="config-update",
            )
            reset_source_data(
                DATABASE_PATH,
                source_key=normalized_source_key,
                source_slug=str(source_record.get("source_slug", "")).strip(),
                server_clip_dir=CLIENT_CLIP_DIR,
            )
            self._reset_remote_source_data(source_record)
            self.start_source(normalized_source_key)
            return get_source(DATABASE_PATH, normalized_source_key) or source_record

        with self._lock:
            existing_worker = self._workers.get(normalized_source_key)
            is_running = existing_worker is not None and existing_worker.thread.is_alive()

        if is_running:
            self.restart_source(normalized_source_key)

        return get_source(DATABASE_PATH, normalized_source_key) or source_record

    def list_registered_sources(self) -> list[dict[str, Any]]:
        return list_sources(DATABASE_PATH)

    def sync_all_to_server(self) -> None:
        for source_record in list_sources(DATABASE_PATH):
            self._sync_source_to_server(source_record)
        for status_record in list_source_statuses(DATABASE_PATH):
            remote_server_reporter.post_status(status_record)

    def start_source(self, source_key: str) -> dict[str, Any]:
        normalized_source_key = source_key.strip()
        source_record = get_source(DATABASE_PATH, normalized_source_key)
        if source_record is None:
            raise KeyError(normalized_source_key)

        set_source_desired_running(
            DATABASE_PATH,
            source_key=normalized_source_key,
            desired_running=True,
        )
        latest_source_record = get_source(DATABASE_PATH, normalized_source_key)
        if latest_source_record is not None:
            self._sync_source_to_server(latest_source_record)
        with self._lock:
            existing_worker = self._workers.get(normalized_source_key)
            if existing_worker is not None and existing_worker.thread.is_alive():
                return source_record

            previous_status = get_source_status(DATABASE_PATH, normalized_source_key) or {}
            stop_event = threading.Event()
            thread = threading.Thread(
                target=self._run_worker,
                args=(normalized_source_key, dict(source_record), stop_event),
                name=f"analysis-worker-{normalized_source_key}",
                daemon=True,
            )
            self._workers[normalized_source_key] = _ManagedWorker(
                source_record=dict(source_record),
                stop_event=stop_event,
                thread=thread,
            )
            log_line(
                "SRC",
                action="start",
                source=normalized_source_key,
                type=source_record["source_type"],
                client=source_record["client_id"] or "-",
            )
            self._upsert_status_and_sync(
                {
                    "source_key": normalized_source_key,
                    "source_type": source_record["source_type"],
                    "source_value": source_record["source_value"],
                    "client_id": source_record["client_id"],
                    "session_id": source_record["session_id"],
                    "state": "starting",
                    "is_running": False,
                    "source_fps": float(previous_status.get("source_fps", 0.0) or 0.0),
                    "last_frame_id": int(previous_status.get("last_frame_id", -1) or -1),
                    "last_source_time_seconds": float(
                        previous_status.get("last_source_time_seconds", 0.0) or 0.0
                    ),
                    "error_message": "",
                }
            )
            thread.start()
        return get_source(DATABASE_PATH, normalized_source_key) or source_record

    def stop_source(
        self,
        source_key: str,
        *,
        update_desired_running: bool = True,
        stop_reason: str = "api-stop",
    ) -> dict[str, Any] | None:
        normalized_source_key = source_key.strip()
        if update_desired_running:
            set_source_desired_running(
                DATABASE_PATH,
                source_key=normalized_source_key,
                desired_running=False,
            )
            latest_source_record = get_source(DATABASE_PATH, normalized_source_key)
            if latest_source_record is not None:
                self._sync_source_to_server(latest_source_record)

        worker: _ManagedWorker | None = None
        with self._lock:
            worker = self._workers.pop(normalized_source_key, None)
        if worker is not None:
            worker.stop_reason = stop_reason
            log_line(
                "SRC",
                action="stop-request",
                source=normalized_source_key,
                reason=stop_reason,
            )
            worker.stop_event.set()
            worker.thread.join(timeout=10.0)

        source_record = get_source(DATABASE_PATH, normalized_source_key)
        if source_record is not None:
            previous_status = get_source_status(DATABASE_PATH, normalized_source_key) or {}
            self._upsert_status_and_sync(
                {
                    "source_key": normalized_source_key,
                    "source_type": source_record["source_type"],
                    "source_value": source_record["source_value"],
                    "client_id": source_record["client_id"],
                    "session_id": source_record["session_id"],
                    "state": "stopped",
                    "is_running": False,
                    "source_fps": float(previous_status.get("source_fps", 0.0) or 0.0),
                    "last_frame_id": int(previous_status.get("last_frame_id", -1) or -1),
                    "last_source_time_seconds": float(
                        previous_status.get("last_source_time_seconds", 0.0) or 0.0
                    ),
                    "error_message": "",
                }
            )
        return source_record

    def restart_source(self, source_key: str) -> dict[str, Any]:
        self.stop_source(source_key, stop_reason="api-restart")
        return self.start_source(source_key)

    def remove_source(self, source_key: str, *, clear_data: bool = False) -> bool:
        source_record = get_source(DATABASE_PATH, source_key)
        if source_record is None:
            return False
        self.stop_source(source_key, stop_reason="remove-source")
        if clear_data:
            reset_source_data(
                DATABASE_PATH,
                source_key=source_key,
                source_slug=str(source_record.get("source_slug", "")).strip(),
                server_clip_dir=CLIENT_CLIP_DIR,
            )
            self._delete_managed_source_file(source_record)
        deleted = delete_source(DATABASE_PATH, source_key)
        delete_source_status(DATABASE_PATH, source_key)
        prune_orphan_source_data(DATABASE_PATH)
        remote_server_reporter.delete_source(
            source_key,
            clear_data=clear_data,
            client_id=str(source_record.get("client_id", "")).strip(),
            session_id=str(source_record.get("session_id", "")).strip(),
        )
        return deleted

    def _delete_managed_source_file(self, source_record: dict[str, Any]) -> None:
        source_type = str(source_record.get("source_type", "")).strip().lower()
        source_value = str(source_record.get("source_value", "")).strip()
        if source_type != "video" or not source_value:
            return

        try:
            file_path = Path(source_value).resolve()
            managed_roots = (
                CLIENT_UPLOAD_SOURCE_DIR.resolve(),
                CLIENT_SOURCE_CACHE_DIR.resolve(),
            )
        except OSError:
            return

        normalized_file = str(file_path).replace("\\", "/").lower()
        is_managed_file = False
        for managed_root in managed_roots:
            normalized_root = str(managed_root).replace("\\", "/").lower()
            if normalized_file.startswith(f"{normalized_root}/"):
                is_managed_file = True
                break
        if not is_managed_file:
            return
        if file_path.exists() and file_path.is_file():
            file_path.unlink(missing_ok=True)

    def _remove_stale_local_camera_sources(self, *, keep_source_key: str = "") -> None:
        current_client_id = _read_configured_client_id() or _build_default_client_id()
        keep_source_key = keep_source_key.strip()
        for source_record in list_sources(DATABASE_PATH):
            source_key = str(source_record.get("source_key", "")).strip()
            if not source_key or source_key == keep_source_key:
                continue
            source_type = str(source_record.get("source_type", "")).strip().lower()
            source_value = str(source_record.get("source_value", "")).strip()
            client_id = str(source_record.get("client_id", "")).strip()
            if (
                source_type != "camera"
                or source_value != "0"
                or client_id == current_client_id
            ):
                continue

            self.stop_source(
                source_key,
                update_desired_running=False,
                stop_reason="remove-stale-local",
            )
            delete_source(DATABASE_PATH, source_key)
            delete_source_status(DATABASE_PATH, source_key)
            prune_orphan_source_data(DATABASE_PATH)
            is_same_client_family = _canonical_client_id(client_id) == _canonical_client_id(
                current_client_id
            )
            if is_same_client_family:
                remote_server_reporter.delete_source(
                    source_key,
                    clear_data=False,
                    client_id=client_id,
                    session_id=str(source_record.get("session_id", "")).strip(),
                )
            log_line(
                "SRC",
                action=(
                    "remove-stale-camera"
                    if is_same_client_family
                    else "remove-foreign-camera-local"
                ),
                source=source_key,
                client=client_id or "-",
            )

    def _run_worker(
        self,
        source_key: str,
        source_record: dict[str, Any],
        stop_event: threading.Event,
    ) -> None:
        source_type = str(source_record.get("source_type", "")).strip().lower()
        try:
            while not stop_event.is_set():
                previous_status = get_source_status(DATABASE_PATH, source_key) or {}
                resume_from_seconds = 0.0
                if source_type == "video":
                    previous_state = str(previous_status.get("state", "")).strip().lower()
                    previous_time = float(
                        previous_status.get("last_source_time_seconds", 0.0) or 0.0
                    )
                    if previous_state != "completed" and previous_time > 0.0:
                        resume_from_seconds = max(previous_time - 1.0, 0.0)

                stop_reason = "stopped"
                error_message = ""
                try:
                    pipeline = build_pipeline_for_source(
                        source_record,
                        restart_checker=lambda: stop_event.is_set(),
                        resume_from_seconds=resume_from_seconds,
                    )
                    stop_reason = pipeline.run()
                except Exception as error:
                    stop_reason = "error"
                    error_message = str(error)
                    log_line(
                        "ERROR",
                        message="analysis worker failed",
                        source=source_key,
                        error=error,
                    )

                if stop_event.is_set():
                    stop_reason = "stopped"

                if stop_reason == "completed":
                    set_source_desired_running(
                        DATABASE_PATH,
                        source_key=source_key,
                        desired_running=False,
                    )

                source_state = get_source(DATABASE_PATH, source_key) or source_record
                if stop_reason != "source_changed":
                    previous_status = get_source_status(DATABASE_PATH, source_key) or {}
                    next_error_message = error_message
                    next_state = stop_reason
                    if (
                        source_type in {"stream", "camera"}
                        and not stop_event.is_set()
                        and bool((get_source(DATABASE_PATH, source_key) or {}).get("desired_running", False))
                        and stop_reason in {"disconnected", "error"}
                    ):
                        next_state = "reconnecting"
                        if not next_error_message:
                            next_error_message = "입력 연결이 끊겨 재시도 중입니다."
                    self._upsert_status_and_sync(
                        {
                            "source_key": source_key,
                            "source_type": source_state["source_type"],
                            "source_value": source_state["source_value"],
                            "client_id": source_state["client_id"],
                            "session_id": source_state["session_id"],
                            "state": next_state,
                            "is_running": False,
                            "source_fps": float(
                                previous_status.get("source_fps", 0.0) or 0.0
                            ),
                            "last_frame_id": int(
                                previous_status.get("last_frame_id", -1) or -1
                            ),
                            "last_source_time_seconds": float(
                                previous_status.get("last_source_time_seconds", 0.0)
                                or 0.0
                            ),
                            "error_message": next_error_message,
                        }
                    )

                if not self._should_retry_source(
                    source_key=source_key,
                    source_type=source_type,
                    stop_reason=stop_reason,
                    stop_event=stop_event,
                ):
                    log_line(
                        "SRC",
                        action="stop",
                        source=source_key,
                        reason=stop_reason,
                    )
                    break

                log_line(
                    "SRC",
                    action="retry",
                    source=source_key,
                    type=source_type,
                    reason=stop_reason,
                    wait="2.0s",
                )
                time.sleep(2.0)
        finally:
            with self._lock:
                self._workers.pop(source_key, None)

    def _should_retry_source(
        self,
        *,
        source_key: str,
        source_type: str,
        stop_reason: str,
        stop_event: threading.Event,
    ) -> bool:
        if stop_event.is_set():
            return False
        if source_type == "video":
            return False
        if source_type not in {"stream", "camera"}:
            return False
        if stop_reason in {"completed", "disconnected", "error"}:
            source_state = get_source(DATABASE_PATH, source_key)
            return bool(source_state and source_state.get("desired_running", False))
        return False

    def _sync_source_to_server(self, source_record: dict[str, Any]) -> None:
        payload = dict(source_record)
        payload["rule_config"] = normalize_rule_config(payload.get("rule_config"))
        payload["source_duration_seconds"] = float(
            payload.get("source_duration_seconds", 0.0) or 0.0
        )
        # Original media stays on the client for every source type.
        payload["server_media_path"] = ""
        payload["media_url"] = ""
        payload["preview_url"] = ""
        remote_server_reporter.upsert_source(payload)

    def _upsert_status_and_sync(self, status_record: dict[str, Any]) -> dict[str, Any]:
        saved_record = upsert_source_status(DATABASE_PATH, status_record)
        remote_server_reporter.post_status(saved_record)
        return saved_record

    def _reset_remote_source_data(self, source_record: dict[str, Any]) -> None:
        remote_server_reporter.reset_source_data(
            source_key=str(source_record.get("source_key", "")).strip(),
            source_slug=str(source_record.get("source_slug", "")).strip(),
        )

    def _start_server_presence_loop(self) -> None:
        if self._server_presence_thread is not None and self._server_presence_thread.is_alive():
            return
        self._server_presence_stop.clear()
        self._server_presence_thread = threading.Thread(
            target=self._run_server_presence_loop,
            name="server-presence-loop",
            daemon=True,
        )
        self._server_presence_thread.start()

    def _run_server_presence_loop(self) -> None:
        while not self._server_presence_stop.wait(self._server_presence_interval_seconds):
            try:
                self._sync_server_presence()
            except Exception as error:
                log_line("WARN", message="server presence sync failed", error=error)

    def _sync_server_presence(self) -> None:
        for source_record in list_sources(DATABASE_PATH):
            source_key = str(source_record.get("source_key", "")).strip()
            if not source_key:
                continue
            self._sync_source_to_server(source_record)

        for status_record in list_source_statuses(DATABASE_PATH):
            source_key = str(status_record.get("source_key", "")).strip()
            if not source_key:
                continue
            latest_source = get_source(DATABASE_PATH, source_key)
            if latest_source is None:
                continue
            heartbeat_status = dict(status_record)
            heartbeat_status["updated_at"] = datetime.now().isoformat()
            self._upsert_status_and_sync(heartbeat_status)


def _build_default_client_id() -> str:
    hostname = socket.gethostname().strip().lower()
    normalized = "".join(char if char.isalnum() else "_" for char in hostname)
    normalized = "_".join(part for part in normalized.split("_") if part)
    return f"client_{normalized}" if normalized else "client_local"


def _read_configured_client_id() -> str:
    try:
        decoded = json.loads(CLIENT_SETTINGS_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return ""
    if not isinstance(decoded, dict):
        return ""
    return str(decoded.get("client_id", "")).strip()


def _canonical_client_id(client_id: str) -> str:
    normalized = client_id.strip().lower()
    parts = normalized.rsplit("_", 1)
    if (
        len(parts) == 2
        and len(parts[1]) == 6
        and all(char in "0123456789abcdef" for char in parts[1])
    ):
        return parts[0]
    return normalized
