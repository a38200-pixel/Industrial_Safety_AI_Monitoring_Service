# Safety Monitor Workspace

CCTV/웹캠 기반 안전 모니터링 시스템입니다. 전체 구조는 `클라이언트 -> 서버 -> 뷰어` 흐름으로 동작합니다.

- 클라이언트는 각 PC의 카메라를 열고 객체 탐지만 수행합니다.
- 서버는 클라이언트가 보낸 탐지 결과를 저장하고, 서버 DB의 룰 설정 기준으로 이벤트를 판정합니다.
- 뷰어는 서버 API를 통해 실시간 프리뷰, 이벤트 로그, 클립, 룰 설정을 관리합니다.

자세한 실행 절차는 [RUN_GUIDE.md](RUN_GUIDE.md)를 기준으로 합니다.
자세한 의존성 목록은 [DEPENDENCIES.md](DEPENDENCIES.md)를 기준으로 합니다.


## 필수 외부 의존성

`install_dependencies.bat`은 Python 가상환경, pip 패키지, Flutter pub 패키지를 설치합니다. Windows 앱 빌드에 필요한 외부 도구는 사용자가 먼저 설치해야 합니다.

필수 항목:

- Python 3.12: 서버와 클라이언트 내장 백엔드 실행에 필요합니다.
- Windows 개발자 모드: Flutter Windows 빌드의 symlink 생성에 필요합니다.
  - 설정 경로: `설정 > 시스템 > 개발자용 > 개발자 모드 > 켬`
- Flutter SDK for Windows: 클라이언트/뷰어 Flutter Windows 앱 빌드에 필요합니다.
  - 권장 위치: 워크스페이스 루트의 `flutter\bin\flutter.bat`
  - 또는 `flutter\bin`을 PATH에 추가합니다.
- Visual Studio Build Tools 또는 Visual Studio Community
  - `Desktop development with C++` 워크로드
  - MSVC v143 또는 최신 C++ x64/x86 build tools
  - Windows 10/11 SDK
  - CMake tools for Windows
- Git: `git pull`, `core.longpaths` 설정, 협업용으로 필요합니다.

AI 클라이언트에서 TensorRT engine을 만들거나 CUDA 추론을 사용할 경우 다음 항목도 필요합니다.

- NVIDIA GPU와 호환 드라이버
- CUDA 호환 PyTorch 패키지: `requirements.txt`에서 설치합니다.
- TensorRT Python 패키지: `requirements.txt`에서 설치합니다.

`install_dependencies.bat client`, `install_dependencies.bat viewer`, `install_dependencies.bat all`은 개발자 모드, Flutter SDK, Visual Studio C++ Build Tools, Windows SDK, CMake tools를 먼저 검사합니다. 누락된 외부 도구는 자동 설치하지 않고 안내 메시지와 함께 중단합니다.

환경 확인은 워크스페이스 루트에서 아래 명령으로 먼저 수행합니다.

```bat
check_environment.bat
```

## 현재 운영 정책

- PC 1대당 클라이언트 1개 실행을 기준으로 합니다.
- 클라이언트 1개는 로컬 `0`번 카메라 1개를 사용합니다.
- 클라이언트는 룰 판정이나 이벤트 저장을 하지 않습니다.
- 룰 판정, 이벤트 DB 저장, 이벤트 클립/썸네일 관리는 서버가 담당합니다.
- 뷰어는 서버에만 접속하며 클라이언트에 직접 접속하지 않습니다.
- 연결이 끊긴 클라이언트는 뷰어 화면에서 숨겨지고, 다시 연결되면 기존 `source_key`와 `display_name` 기준으로 다시 표시됩니다.

## 프로젝트 구성

```text
safety_monitor_workspace/
├─ safety_monitor_client/          # Flutter 클라이언트 GUI + 내장 FastAPI 백엔드
├─ safety_monitor_server/          # 중앙 FastAPI 서버
├─ safety_monitor_viewer/          # Flutter 관제 뷰어
├─ client_server_viewer_model/     # 학습/설명용 미니 구조 예제
├─ docs/                           # 보조 문서
├─ scripts/                        # 설정/정리 PowerShell 스크립트
├─ RUN_GUIDE.md                    # 빌드/실행 가이드
├─ DB_SCHEMA.md                    # DB 구조 설명
├─ requirements.txt                # 클라이언트 내장 백엔드 의존성
└─ requirements-server.txt         # 서버 의존성
```

## 클라이언트

경로: `safety_monitor_client/`

역할:

- 로컬 PC의 `0`번 카메라를 사용합니다.
- YOLO 모델로 객체 탐지를 수행합니다.
- 서버로 source 등록, heartbeat, preview frame, frame detection 결과를 전송합니다.
- 이벤트 룰 판정은 하지 않습니다.
- 현재 GUI는 최소 상태 확인용이며, 향후 백그라운드 실행 형태로 줄일 수 있습니다.

내장 백엔드:

- 경로: `safety_monitor_client/embedded_backend/`
- 클라이언트 GUI와 Python 분석 프로세스 사이의 로컬 FastAPI 계층입니다.
- 기본 로컬 주소는 `http://127.0.0.1:8100`입니다.

모델 출력 기준:

```text
0: YES_Helmet
1: NO_Helmet
2: Person
```

탐지 박스 표시 색상:

- `YES_Helmet`: 초록
- `NO_Helmet`: 빨강
- `Person`: 노랑

`Person` 추적은 `IoU + 박스 크기 기반 동적 거리`를 사용해 같은 객체를 이어 봅니다. 내부 `track_id`는 이벤트 그룹핑용으로 유지하지만, 일반 UI 라벨에는 표시하지 않습니다.

## 서버

경로: `safety_monitor_server/`

역할:

- 클라이언트 source 등록 정보 저장
- 클라이언트 heartbeat/source status 저장
- 프리뷰 프레임과 프레임 탐지 결과 저장
- 서버 기준 룰 판정
- 이벤트 DB 저장
- 이벤트 클립 MP4와 썸네일 JPG 관리
- 뷰어용 API와 실시간 상태 제공

중요 원칙:

- 서버가 유일한 이벤트 판정 주체입니다.
- 클라이언트가 보낸 객체 탐지 결과를 보고 `server_event_processor`가 룰을 적용합니다.
- 뷰어에서 변경한 룰 설정은 서버 DB에 저장됩니다.

현재 룰:

- 안전모 미착용 룰: `NO_Helmet` 탐지 기준
- 위험구역 룰: `Person` 박스가 ROI와 겹치면 이벤트 발생

## 뷰어

경로: `safety_monitor_viewer/`

역할:

- 서버에 연결된 카메라 목록 표시
- Live Monitoring 그리드 표시
- 이벤트 로그, 썸네일, 클립 조회
- 이벤트 클릭 시 해당 카메라 타일에서 클립 재생
- 카메라별 룰 설정 변경
- 위험구역 ROI 편집/저장
- 테스트용 DB Clear 수행

UI 흐름:

- 상단에서 서버 URL을 입력하고 `Apply Server`로 적용합니다.
- 좌측 카메라 패널에서 카메라를 선택/선택 해제합니다.
- 카메라 이름은 뷰어에서 편집할 수 있고 서버 DB에 저장됩니다.
- 좌측 카메라 목록과 중앙 그리드에서 드래그로 카메라 표시 순서를 바꿀 수 있습니다.
- 중앙 Live Monitoring은 기본 2열 그리드입니다.
- 5개 이상 연결되면 Live Monitoring 내부 스크롤로 확인합니다.
- 타일 우상단 최대화 버튼을 누르면 해당 영상만 크게 표시합니다.
- 우측 이벤트 로그는 선택된 카메라가 있으면 해당 카메라 이벤트만, 선택이 없으면 전체 이벤트를 보여줍니다.
- 이벤트를 클릭하면 상세 패널 대신 해당 카메라 타일에서 이벤트 클립을 재생합니다.

위험구역 ROI 편집:

1. 카메라를 선택합니다.
2. `위험구역 드래그 편집`을 누릅니다.
3. 기존 ROI가 있으면 영상 위에 표시됩니다.
4. 영상 위에서 ROI를 드래그합니다.
5. 드래그 중에는 임시 ROI만 표시됩니다.
6. `위험구역 편집 종료`를 누르면 서버에 저장됩니다.
7. ROI 저장만으로 위험구역 룰이 자동 ON 되지는 않습니다.

## 카메라 식별/이름 정책

내부 식별자는 `source_key`를 사용합니다.

- `source_key`는 클라이언트/소스 소유권을 구분하는 기술 키입니다.
- 현재 클라이언트 식별자는 PC hostname 기반 `client_<hostname>` 형태를 기본으로 합니다.
- 사용자가 보는 이름은 `display_name`입니다.
- 뷰어에서 카메라 이름을 편집하면 서버 DB에 저장됩니다.
- 같은 `source_key`가 다시 연결되면 기존 `display_name`을 다시 사용합니다.

이 방식은 IP 변경에는 비교적 강하지만, PC 자체가 바뀌면 새 source로 볼 수 있습니다. 향후 물리 카메라 위치 중심의 슬롯 재매핑 기능으로 확장할 수 있습니다.

## 데이터 흐름

1. 클라이언트가 로컬 카메라를 열고 서버에 source를 등록합니다.
2. 클라이언트가 프레임을 분석해 객체 탐지 결과를 만듭니다.
3. 클라이언트가 preview frame, frame detection, source status를 서버로 전송합니다.
4. 서버가 source별 rule config를 조회합니다.
5. 서버가 탐지 결과에 룰을 적용해 이벤트를 생성/종료합니다.
6. 서버가 이벤트 DB, 클립, 썸네일을 저장합니다.
7. 뷰어가 서버 API로 카메라 상태, 실시간 프리뷰, 이벤트 로그, 클립을 조회합니다.
8. 뷰어에서 룰/ROI/display_name을 변경하면 서버 DB에 저장됩니다.

## 실행 요약

처음 받은 PC에서는 아래 순서를 권장합니다.

```bat
check_environment.bat
install_dependencies.bat all
build_viewer.bat
build_client.bat
```

실행 순서:

```bat
run_server.bat
run_viewer.bat
run_client.bat
```

다른 PC에서 서버에 접속할 때는 `127.0.0.1`이 아니라 서버 PC의 IPv4 주소를 사용합니다.

```text
http://<서버PC IPv4>:8000
```

더 자세한 절차와 오류 대응은 [RUN_GUIDE.md](RUN_GUIDE.md)를 확인합니다.

## 경로 정책

Windows Flutter 빌드는 경로가 길면 실패하기 쉽습니다. 저장소는 C 또는 D 드라이브 루트 근처의 짧은 경로에 둡니다.

권장:

```text
C:\safety_monitor_workspace
D:\safety_monitor_workspace
C:\hiyoung_team_github\safety_monitor_workspace
```

피해야 할 위치:

```text
Desktop
OneDrive
Downloads
문서 폴더 깊은 하위 경로
```

빌드 배치파일은 `C:\smw_build_client`, `C:\smw_build_viewer` junction을 임시로 사용해 Windows 경로 길이 문제를 줄입니다.

## 주요 배치파일

- `check_environment.bat`: Python/Windows 개발자 모드/Flutter/Visual Studio C++/Windows SDK 환경 확인
- `install_dependencies.bat`: Python 의존성 및 Flutter pub 의존성 설치
- `build_client.bat`: 클라이언트 Windows 빌드
- `build_viewer.bat`: 뷰어 Windows 빌드
- `run_server.bat`: 서버 실행
- `run_client.bat`: 클라이언트 실행
- `run_viewer.bat`: 뷰어 실행
- `setup_server_firewall.bat`: 서버 PC TCP 8000 방화벽 허용

## 참고 문서

- [RUN_GUIDE.md](RUN_GUIDE.md): 실행/빌드 절차
- [DB_SCHEMA.md](DB_SCHEMA.md): DB 테이블 구조
- [docs/FASTAPI_PROJECT_SUMMARY.md](docs/FASTAPI_PROJECT_SUMMARY.md): FastAPI 사용 구조 설명
