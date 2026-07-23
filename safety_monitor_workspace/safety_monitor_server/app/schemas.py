# 프로젝트 여러 곳에서 함께 사용하는 보조 코드 파일입니다.
# 상수, 스키마, 로그 같은 공통 흐름을 담고 있습니다.

from typing import Any

from pydantic import BaseModel

# 이 파일은 FastAPI 응답 모델 모음입니다.
# Pydantic 모델은 서버가 어떤 JSON 형태를 돌려주는지 문서처럼 보여 주는 역할도 합니다.

class EventListResponse(BaseModel):
    count: int
    items: list[dict[str, Any]]


class SourceSummaryItem(BaseModel):
    source_key: str
    source_type: str
    source_value: str
    event_count: int
    latest_received_at: str


class SourceSummaryListResponse(BaseModel):
    count: int
    items: list[SourceSummaryItem]


class SourceItem(BaseModel):
    source_key: str
    source_slug: str
    display_name: str = ""
    source_type: str
    source_value: str
    source_duration_seconds: float = 0.0
    server_media_path: str = ""
    media_url: str = ""
    preview_url: str = ""
    original_source_type: str = ""
    original_source_value: str = ""
    client_id: str = ""
    session_id: str = ""
    desired_running: bool = True
    rule_config: dict[str, Any] = {}
    created_at: str
    updated_at: str


class SourceListResponse(BaseModel):
    count: int
    items: list[SourceItem]


class SourceOverviewItem(BaseModel):
    client_id: str = ""
    session_id: str = ""
    source_key: str
    source_slug: str = ""
    display_name: str = ""
    source_type: str
    source_value: str
    source_duration_seconds: float = 0.0
    media_url: str = ""
    preview_url: str = ""
    desired_running: bool = False
    state: str = "unknown"
    is_running: bool = False
    source_fps: float = 0.0
    last_frame_id: int = -1
    last_source_time_seconds: float = 0.0
    last_event_received_at: str = ""
    last_frame_received_at: str = ""
    error_message: str = ""
    updated_at: str = ""


class SourceOverviewListResponse(BaseModel):
    count: int
    items: list[SourceOverviewItem]


class SourceCreateRequest(BaseModel):
    source_type: str
    source_value: str
    client_id: str = ""
    session_id: str = ""
    reset_existing: bool = True
    start_immediately: bool = True


class SourceUpsertResponse(BaseModel):
    ok: bool
    item: SourceItem


class SourceConfigUpdateRequest(BaseModel):
    rule_config: dict[str, Any]




class SourceDisplayNameUpdateRequest(BaseModel):
    display_name: str = ""

class SourceActionResponse(BaseModel):
    ok: bool
    source_key: str
    state: str


class SourceStatusItem(BaseModel):
    source_key: str
    source_type: str
    source_value: str
    client_id: str = ""
    session_id: str = ""
    state: str
    is_running: bool
    source_fps: float = 0.0
    source_duration_seconds: float = 0.0
    last_frame_id: int = -1
    last_source_time_seconds: float = 0.0
    error_message: str = ""
    updated_at: str


class SourceStatusListResponse(BaseModel):
    count: int
    items: list[SourceStatusItem]


class SourceStatusUpsertResponse(BaseModel):
    ok: bool
    item: dict[str, Any]


class EventDetailResponse(BaseModel):
    event_key: str
    item: dict[str, Any]


class EventHistoryResponse(BaseModel):
    event_key: str
    count: int
    items: list[dict[str, Any]]


class EventCreateResponse(BaseModel):
    ok: bool
    item: dict[str, Any]


class ClipItem(BaseModel):
    name: str
    path: str
    url: str


class ClipListResponse(BaseModel):
    count: int
    items: list[ClipItem]


class ClipUploadResponse(BaseModel):
    ok: bool
    name: str
    path: str
    url: str
    size_bytes: int
    event_key: str | None = None


class FrameDetectionCreateResponse(BaseModel):
    ok: bool
    item: dict[str, Any]


class FrameDetectionSnapshotResponse(BaseModel):
    found: bool
    item: dict[str, Any] | None


class HealthResponse(BaseModel):
    status: str
    event_log_path: str
    event_log_exists: bool


class ResetDataResponse(BaseModel):
    ok: bool
    source_key: str
    cleared_events: bool
    deleted_event_count: int
    deleted_clip_count: int
