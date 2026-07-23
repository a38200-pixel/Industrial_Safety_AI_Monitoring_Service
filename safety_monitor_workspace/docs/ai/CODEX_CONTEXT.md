# CODEX_CONTEXT.md

## 프로젝트 한 줄 요약

클라이언트가 카메라 프레임을 분석하고, 서버가 룰을 적용해 이벤트/클립/썸네일을 저장하며, 뷰어가 관제와 룰 설정을 담당하는 안전 모니터링 프로젝트입니다.

## 핵심 디렉터리

- `safety_monitor_client/`
  - Flutter 클라이언트
  - 내장 Python 분석 백엔드 포함
  - 현재는 GUI가 있으나 장기적으로 headless 실행 가능성을 고려
- `safety_monitor_server/`
  - FastAPI 서버
  - 중앙 DB, 프리뷰, 이벤트, 클립, 썸네일 관리
- `safety_monitor_viewer/`
  - 서버 조회/관제용 Flutter 뷰어
  - 카메라 선택, 이벤트 로그, 클립 재생, 룰 설정 UI 담당

## 먼저 볼 파일

### 클라이언트

- `safety_monitor_client/lib/screens/home_screen.dart`
- `safety_monitor_client/embedded_backend/app/source_manager.py`
- `safety_monitor_client/embedded_backend/app/analysis_runtime.py`
- `safety_monitor_client/embedded_backend/app/reporting_api.py`

### 서버

- `safety_monitor_server/main.py`
- `safety_monitor_server/app/server_event_processor.py`
- `safety_monitor_server/app/server_clip_recorder.py`
- `safety_monitor_server/app/database.py`
- `safety_monitor_server/app/routers/sources.py`
- `safety_monitor_server/app/routers/events.py`
- `safety_monitor_server/app/routers/frame_detections.py`
- `safety_monitor_server/app/routers/source_status.py`
- `safety_monitor_server/app/routers/source_streams.py`
- `safety_monitor_server/app/routers/event_thumbnails.py`
- `safety_monitor_server/app/routers/admin.py`

### 뷰어

- `safety_monitor_viewer/lib/screens/home_screen.dart`
- `safety_monitor_viewer/lib/widgets/video_view_box.dart`
- `safety_monitor_viewer/lib/widgets/event_log_box.dart`
- `safety_monitor_viewer/lib/services/event_api_service.dart`
- `safety_monitor_viewer/lib/controllers/api_event_controller.dart`
- `safety_monitor_viewer/lib/controllers/video_panel_controller.dart`

## 중요한 현재 사실

- 클라이언트는 현재 PC의 `0`번 카메라를 소유합니다.
- 클라이언트가 객체 탐지를 수행합니다.
- 서버는 탐지 결과와 소스별 `rule_config`를 이용해 이벤트를 판정합니다.
- 서버는 이벤트 종료 시 프리뷰 버퍼에서 MP4 클립과 JPG 썸네일을 생성합니다.
- 뷰어는 좌측 카메라 리스트, 중앙 영상 그리드, 우측 이벤트/룰 패널을 가집니다.
- 선택된 카메라가 있으면 해당 소스 이벤트만, 선택이 없으면 전체 이벤트를 보여줍니다.
- 이벤트 클릭 시 해당 카메라 타일에서 클립을 재생합니다.
- 위험구역 이벤트 클립은 이벤트 당시 `danger_zone_roi`를 오버레이합니다.
- ROI 드래그는 즉시 저장하지 않고 `위험구역 편집 종료` 시 저장합니다.
- ROI 저장만으로 위험구역 룰 토글이 자동 ON 되지 않습니다.

## 주의할 점

- `source_key` 규칙을 바꾸면 상태 조회, 이벤트 조회, 프리뷰 조회, 클립 연결이 함께 영향을 받습니다.
- 사용자 표시명은 `source_key`와 분리하는 것이 좋습니다.
- 현재 UI 표시명은 임시로 `카메라 1`, `카메라 2` 순번 표시를 사용합니다.
- 장기적으로는 물리 카메라 슬롯/사용자 별칭과 현재 연결 클라이언트를 분리하는 설계가 필요합니다.
- 뷰어는 객체 탐지를 직접 수행하지 않습니다.
- 뷰어는 소스별 룰 설정을 서버에 저장할 수 있습니다.
