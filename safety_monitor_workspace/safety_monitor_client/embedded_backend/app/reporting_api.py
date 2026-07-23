# 프로젝트 여러 곳에서 함께 사용하는 보조 코드 파일입니다.
# 상수, 스키마, 로그 같은 공통 흐름을 담고 있습니다.

from __future__ import annotations

from pathlib import Path
from typing import Any

import requests

from app.config import HTTP_TIMEOUT_SECONDS
from app.config import REMOTE_SERVER_BASE_URL
from app.log_utils import log_line


class RemoteServerReporter:
    def __init__(self, base_url: str = REMOTE_SERVER_BASE_URL) -> None:
        self.base_url = base_url.rstrip("/")

    def set_base_url(self, base_url: str) -> None:
        normalized = base_url.strip().rstrip("/")
        if normalized:
            self.base_url = normalized

    def upsert_source(self, source_record: dict[str, Any]) -> bool:
        return self._post_json("/api/sources", source_record)

    def upload_source_media(
        self,
        *,
        file_path: str,
        source_key: str,
        source_slug: str,
        source_type: str,
        source_value: str,
        original_source_type: str,
        original_source_value: str,
        client_id: str,
        session_id: str,
        reset_existing: bool,
        start_immediately: bool,
    ) -> dict[str, Any] | None:
        source_file = Path(file_path)
        if not source_file.exists() or not source_file.is_file():
            return None
        try:
            with source_file.open("rb") as handle:
                response = requests.post(
                    f"{self.base_url}/api/sources/upload",
                    data={
                        "source_key": source_key,
                        "source_slug": source_slug,
                        "source_type": source_type,
                        "source_value": source_value,
                        "original_source_type": original_source_type,
                        "original_source_value": original_source_value,
                        "client_id": client_id,
                        "session_id": session_id,
                        "reset_existing": "true" if reset_existing else "false",
                        "start_immediately": "true" if start_immediately else "false",
                    },
                    files={
                        "file": (
                            source_file.name,
                            handle,
                            "video/mp4",
                        )
                    },
                    timeout=max(HTTP_TIMEOUT_SECONDS, 60.0),
                )
            response.raise_for_status()
            payload = response.json()
            return payload if isinstance(payload, dict) else None
        except Exception as error:
            log_line(
                "WARN",
                message="remote source media upload failed",
                source=file_path,
                error=error,
            )
            return None

    def delete_source(
        self,
        source_key: str,
        *,
        clear_data: bool,
        client_id: str = "",
        session_id: str = "",
    ) -> bool:
        try:
            response = requests.delete(
                f"{self.base_url}/api/sources/{requests.utils.quote(source_key, safe='')}",
                params={
                    "clear_data": "true" if clear_data else "false",
                    "client_id": client_id.strip(),
                    "session_id": session_id.strip(),
                },
                timeout=HTTP_TIMEOUT_SECONDS,
            )
            response.raise_for_status()
            return True
        except Exception as error:
            log_line("WARN", message="remote source delete failed", source=source_key, error=error)
            return False

    def reset_source_data(self, *, source_key: str, source_slug: str) -> bool:
        try:
            response = requests.post(
                f"{self.base_url}/api/admin/reset-data",
                json={
                    "source_key": source_key,
                    "source_slug": source_slug,
                },
                timeout=HTTP_TIMEOUT_SECONDS,
            )
            response.raise_for_status()
            return True
        except Exception as error:
            log_line(
                "WARN",
                message="remote source reset failed",
                source=source_key,
                error=error,
            )
            return False

    def post_status(self, status_record: dict[str, Any]) -> bool:
        return self._post_json("/api/source-status", status_record)

    def post_frame_detection(self, frame_record: dict[str, Any]) -> bool:
        return self._post_json("/api/frame-detections", frame_record)

    def post_event(self, event_record: dict[str, Any]) -> bool:
        # 클라이언트는 이벤트를 서버로 전송하지 않습니다.
        # 서버가 frame_detections를 기준으로 룰 판정과 이벤트 저장을 담당합니다.
        return False

    def upload_clip(
        self,
        *,
        clip_path: str,
        event_key: str,
        source_key: str,
        source_slug: str,
    ) -> dict[str, Any] | None:
        file_path = Path(clip_path)
        if not file_path.exists() or not file_path.is_file():
            return None

        try:
            with file_path.open("rb") as handle:
                response = requests.post(
                    f"{self.base_url}/api/clips",
                    data={
                        "event_key": event_key,
                        "source_key": source_key,
                        "source_slug": source_slug,
                    },
                    files={"file": (file_path.name, handle, "video/mp4")},
                    timeout=max(HTTP_TIMEOUT_SECONDS, 60.0),
                )
            response.raise_for_status()
            payload = response.json()
            return payload if isinstance(payload, dict) else None
        except Exception as error:
            log_line(
                "WARN",
                message="remote clip upload failed",
                source=source_key,
                event=event_key,
                error=error,
            )
            return None

    def upload_source_preview(
        self,
        *,
        source_key: str,
        preview_path: str,
    ) -> bool:
        file_path = Path(preview_path)
        if not file_path.exists() or not file_path.is_file():
            return False
        try:
            with file_path.open("rb") as handle:
                response = requests.post(
                    f"{self.base_url}/api/source-previews",
                    data={"source_key": source_key},
                    files={"file": (file_path.name, handle, "image/jpeg")},
                    timeout=max(HTTP_TIMEOUT_SECONDS, 30.0),
                )
            response.raise_for_status()
            return True
        except Exception as error:
            log_line(
                "WARN",
                message="remote source preview upload failed",
                source=source_key,
                error=error,
            )
            return False

    def _post_json(self, path: str, payload: dict[str, Any]) -> bool:
        try:
            response = requests.post(
                f"{self.base_url}{path}",
                json=payload,
                timeout=HTTP_TIMEOUT_SECONDS,
            )
            response.raise_for_status()
            return True
        except Exception as error:
            source_key = str(payload.get("source_key", "")).strip()
            log_line("WARN", message="remote post failed", path=path, source=source_key or None, error=error)
            return False


remote_server_reporter = RemoteServerReporter()
