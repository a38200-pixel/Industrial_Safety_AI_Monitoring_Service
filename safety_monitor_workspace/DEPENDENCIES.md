# Safety Monitor 의존성 목록

이 문서는 `requirements.txt`처럼 기계가 설치하는 파일이 아니라, 사람이 프로젝트 실행과 빌드에 필요한 의존성을 한눈에 확인하기 위한 정리 문서입니다.

프로젝트는 크게 `서버`, `클라이언트`, `뷰어` 3개 실행 단위로 나뉩니다.

- 서버: 중앙 FastAPI 서버입니다. 클라이언트가 보낸 탐지 결과를 DB에 저장하고 서버 룰 기준으로 이벤트를 판정합니다.
- 클라이언트: Flutter GUI와 Python 내장 백엔드로 구성됩니다. 카메라를 열고 YOLO 객체 탐지만 수행한 뒤 결과를 서버로 전송합니다.
- 뷰어: Flutter GUI입니다. 서버 API를 호출해서 실시간 모니터링, 이벤트 로그, 클립 재생, 룰 설정, 카메라 이름 관리를 수행합니다.

## 1. 공통 외부 의존성

아래 항목은 Python 패키지나 Flutter 패키지가 아니라 Windows PC에 먼저 준비되어야 하는 실행 환경입니다.

### 운영체제

- Windows 10 또는 Windows 11을 기준으로 합니다.
- Flutter Windows 데스크톱 빌드를 사용하므로 Windows 환경이 필요합니다.

### 작업 경로

- 워크스페이스는 가능한 한 드라이브 루트에 가깝게 둡니다.
  - 권장 예시: `C:\safety_monitor_workspace`, `D:\safety_monitor_workspace`
- Flutter Windows 빌드와 MSBuild 경로 길이 문제를 줄이기 위해 긴 경로는 피합니다.
- 배치파일은 워크스페이스 경로 길이가 너무 길면 중단하도록 되어 있습니다.

### Git

- `git pull`, 협업, 긴 경로 설정에 필요합니다.
- `check_environment.bat`은 `git core.longpaths true` 설정을 시도합니다.

### Python

- Python 3.12를 권장합니다.
- 서버와 클라이언트 내장 백엔드는 Python으로 실행됩니다.
- `install_dependencies.bat`은 `.venv` 가상환경을 만들고 필요한 Python 패키지를 설치합니다.

### Flutter SDK / Dart SDK

- 클라이언트와 뷰어는 Flutter Windows 데스크톱 앱입니다.
- Flutter SDK for Windows가 필요합니다.
- Dart SDK는 Flutter SDK에 포함된 버전을 사용합니다.
- 권장 위치는 워크스페이스 루트의 `flutter\bin\flutter.bat`입니다.
- 또는 `flutter\bin`을 PATH에 추가해도 됩니다.

### Windows 개발자 모드

- Flutter Windows 빌드 중 symlink 생성에 필요합니다.
- 설정 경로: `설정 > 시스템 > 개발자용 > 개발자 모드 > 켬`
- 배치파일은 레지스트리 값을 확인하고 꺼져 있으면 안내 후 중단합니다.

### Visual Studio C++ Build Tools

Flutter Windows 앱 빌드에 필요합니다.

Visual Studio Build Tools 또는 Visual Studio Community에서 아래 구성요소가 필요합니다.

- `Desktop development with C++` 워크로드
- MSVC v143 또는 최신 C++ x64/x86 build tools
- Windows 10/11 SDK
- CMake tools for Windows

`install_dependencies.bat client`, `install_dependencies.bat viewer`, `install_dependencies.bat all` 실행 시 위 항목을 검사합니다.

### 네트워크 / 방화벽

- 서버는 기본적으로 `0.0.0.0:8000`에서 실행됩니다.
- 다른 PC의 클라이언트/뷰어가 서버에 접근하려면 서버 PC 방화벽에서 8000 포트 인바운드 허용이 필요합니다.
- 서버 PC IP 예시: `http://192.168.24.114:8000`

### NVIDIA GPU / CUDA / TensorRT

AI 클라이언트에서 CUDA 추론 또는 TensorRT engine 변환을 사용할 경우 필요합니다.

- NVIDIA GPU
- 호환되는 NVIDIA 드라이버
- CUDA 지원 PyTorch wheel
- TensorRT Python 패키지

PyTorch, TensorRT 관련 Python 패키지는 `requirements.txt`에서 설치합니다. 드라이버와 GPU 자체는 사용자가 별도로 준비해야 합니다.

## 2. 서버 의존성

서버 프로젝트 위치는 `safety_monitor_server`입니다.

서버 설치 기준 파일은 `requirements-server.txt`입니다.

### 서버 실행 명령

```bat
install_dependencies.bat server
run_server.bat
```

### 서버 Python 패키지

#### FastAPI 서버 런타임

- `fastapi==0.136.1`
- `starlette==1.0.0`
- `uvicorn==0.46.0`
- `anyio==4.13.0`
- `h11==0.16.0`
- `click==8.3.3`
- `colorama==0.4.6`

역할:

- HTTP API 라우터 실행
- WebSocket 실시간 알림 처리
- 서버 실행 프로세스 구동

#### 요청 파싱 / 검증

- `python-multipart==0.0.28`
- `pydantic==2.13.4`
- `pydantic_core==2.46.4`
- `annotated-types==0.7.0`
- `annotated-doc==0.0.4`
- `typing_extensions==4.15.0`
- `typing-inspection==0.4.2`

역할:

- API 요청/응답 모델 검증
- 클립, 프리뷰 이미지 같은 multipart 업로드 처리

#### 실시간 통신

- `websockets==16.0`

역할:

- 뷰어와 서버 사이의 실시간 갱신 흐름에 사용됩니다.

#### 영상/이미지 처리

- `numpy==2.4.4`
- `opencv-python==4.13.0.92`

역할:

- 서버에서 이벤트 클립과 썸네일을 생성하거나 저장할 때 사용됩니다.
- 클라이언트가 보낸 프레임 탐지 결과를 서버 기준 이벤트로 판정한 뒤 관련 미디어를 관리합니다.

### 서버 표준 라이브러리 의존성

별도 설치는 필요 없지만 코드에서 중요하게 사용하는 Python 기본 모듈입니다.

- `sqlite3`: 서버 DB 저장소
- `json`: 이벤트/룰/탐지 결과 직렬화
- `datetime`, `time`: 이벤트 시간, 상태 만료, 로그 시간 처리
- `pathlib`, `os`, `shutil`: 파일/폴더 경로와 데이터 정리
- `threading`, `asyncio`: 실시간 허브와 이벤트 처리 동시성
- `uuid`, `hashlib`, `re`: 소스/파일 식별자와 안전한 파일명 처리

### 서버 DB / 파일 저장소

별도 DB 서버는 사용하지 않습니다.

- SQLite 파일 DB를 사용합니다.
- 서버 data 폴더에 이벤트, 클립, 썸네일, 프리뷰 관련 파일을 저장합니다.
- DB clear 기능은 서버 DB와 저장된 클립/썸네일/소스 매칭 정보를 초기화하는 흐름과 연결됩니다.

## 3. 클라이언트 의존성

클라이언트 프로젝트 위치는 `safety_monitor_client`입니다.

클라이언트는 두 부분으로 구성됩니다.

- Flutter GUI
- Python 내장 백엔드

클라이언트 설치 기준 파일은 루트 `requirements.txt`와 `safety_monitor_client/pubspec.yaml`입니다.

### 클라이언트 실행 명령

```bat
install_dependencies.bat client
build_client.bat
run_client.bat
```

개발 중 전체 의존성을 한 번에 맞출 때는 아래 명령을 사용할 수 있습니다.

```bat
install_dependencies.bat all
```

### 클라이언트 Flutter 패키지

`safety_monitor_client/pubspec.yaml` 기준입니다.

#### Flutter SDK

- `flutter`
- Dart SDK `^3.11.5`

역할:

- 클라이언트 GUI 실행
- Windows 데스크톱 앱 빌드

#### UI / 창 관리

- `desktop_multi_window:^0.3.0`

역할:

- 데스크톱 창 관련 기능에 사용됩니다.

#### 파일 선택

- `file_selector:^1.1.0`

역할:

- 파일 기반 소스 선택 기능에 사용됩니다.

#### HTTP 통신

- `http:^1.6.0`

역할:

- Flutter GUI가 로컬 내장 백엔드 또는 서버 API를 호출할 때 사용됩니다.

#### 영상 재생

- `media_kit:^1.2.6`
- `media_kit_video:^2.0.1`
- `media_kit_libs_video:^1.0.7`

역할:

- 클라이언트 GUI의 영상 표시와 미디어 재생에 사용됩니다.

#### 개발용 패키지

- `flutter_test`
- `flutter_lints:^6.0.0`

역할:

- Flutter 테스트와 정적 규칙 확인에 사용됩니다.

### 클라이언트 Python 패키지

루트 `requirements.txt` 기준입니다. 이 파일은 클라이언트 내장 AI 백엔드를 위한 전체 런타임 의존성을 포함하며, 서버 런타임 의존성도 포함합니다.

#### FastAPI 내장 백엔드

- `fastapi==0.136.1`
- `starlette==1.0.0`
- `uvicorn==0.46.0`
- `anyio==4.13.0`
- `h11==0.16.0`
- `click==8.3.3`
- `colorama==0.4.6`

역할:

- 클라이언트 PC 내부에서 로컬 API 서버를 실행합니다.
- Flutter GUI는 Python 코드를 직접 호출하지 않고 로컬 FastAPI를 통해 상태를 조회합니다.

#### 요청 파싱 / 데이터 검증

- `python-multipart==0.0.28`
- `pydantic==2.13.4`
- `pydantic_core==2.46.4`
- `annotated-types==0.7.0`
- `annotated-doc==0.0.4`
- `typing_extensions==4.15.0`
- `typing-inspection==0.4.2`

역할:

- 로컬 API 요청/응답 모델 처리
- 영상 파일, 클립 파일 업로드 형식 처리

#### 네트워크 통신

- `requests==2.33.1`
- `urllib3==2.7.0`
- `charset-normalizer==3.4.7`
- `idna==3.14`
- `certifi==2026.4.22`
- `websockets==16.0`

역할:

- 클라이언트 내장 백엔드가 중앙 서버로 source presence, frame detection, preview, status를 전송합니다.
- 실시간 상태 갱신에 필요한 WebSocket 기반 흐름을 처리합니다.

#### 객체 탐지 / 영상 처리

- `numpy==2.4.4`
- `opencv-python==4.13.0.92`
- `ultralytics==8.4.48`
- `ultralytics-thop==2.0.19`
- `torch==2.11.0+cu128`
- `torchvision==0.26.0+cu128`
- `torchaudio==2.11.0+cu128`
- `tensorrt-cu12==11.0.0.114`
- `onnx==1.21.0`
- `onnxslim==0.1.94`
- `onnxruntime-gpu==1.26.0`
- `wheel==0.47.0`

역할:

- YOLO 모델 로드
- 카메라/영상 프레임 처리
- 객체 탐지 박스 생성
- TensorRT engine 변환 및 실행
- ONNX/ONNX Runtime 기반 변환 보조

현재 설계에서 클라이언트는 룰 판정을 하지 않습니다. 클라이언트는 객체 탐지 결과만 서버로 전송하고, 안전모 미착용/위험구역 이벤트 판정은 서버에서 수행합니다.

#### PyTorch / Ultralytics 보조 의존성

- `filelock==3.29.0`
- `fsspec==2026.4.0`
- `Jinja2==3.1.6`
- `MarkupSafe==3.0.3`
- `mpmath==1.3.0`
- `networkx==3.6.1`
- `packaging==26.2`
- `pillow==12.2.0`
- `PyYAML==6.0.3`
- `setuptools==70.2.0`
- `sympy==1.14.0`

역할:

- PyTorch, Ultralytics, 모델 변환, 이미지 처리에서 필요한 보조 패키지입니다.

#### 과학 연산 / 유틸리티

- `contourpy==1.3.3`
- `cycler==0.12.1`
- `fonttools==4.62.1`
- `kiwisolver==1.5.0`
- `matplotlib==3.10.9`
- `polars==1.40.1`
- `polars-runtime-32==1.40.1`
- `psutil==7.2.2`
- `pygame==2.6.1`
- `pyparsing==3.3.2`
- `python-dateutil==2.9.0.post0`
- `scipy==1.17.1`
- `six==1.17.0`

역할:

- Ultralytics와 관련 도구가 사용하는 과학 연산/시각화/시스템 정보 의존성입니다.

#### 영상 소스 보조

- `yt-dlp==2026.3.17`

역할:

- URL 기반 영상 소스 처리를 보조합니다.

### 클라이언트 표준 라이브러리 의존성

별도 설치는 필요 없습니다.

- `sqlite3`: 클라이언트 로컬 상태 DB
- `socket`: 호스트명 기반 source key 생성에 사용
- `threading`, `queue`, `asyncio`: 카메라 프레임 처리와 백그라운드 작업
- `pathlib`, `os`, `sys`: 경로와 실행 환경 처리
- `json`, `hashlib`, `datetime`: 상태, 탐지 결과, 이벤트 관련 데이터 처리

### 클라이언트 런타임 자산

패키지는 아니지만 실행에 필요한 파일입니다.

- YOLO `.pt` 가중치 파일
- TensorRT `.engine` 파일
- 카메라 장치 또는 영상 파일/스트림

`.engine` 파일은 환경과 GPU에 영향을 받으므로, 필요하면 해당 PC에서 다시 생성하는 것을 권장합니다.

## 4. 뷰어 의존성

뷰어 프로젝트 위치는 `safety_monitor_viewer`입니다.

뷰어는 Flutter 앱이며 별도의 Python 백엔드를 실행하지 않습니다. 서버 FastAPI를 직접 호출합니다.

### 뷰어 실행 명령

```bat
install_dependencies.bat viewer
build_viewer.bat
run_viewer.bat
```

### 뷰어 Flutter 패키지

`safety_monitor_viewer/pubspec.yaml` 기준입니다.

#### Flutter SDK

- `flutter`
- Dart SDK `^3.11.5`

역할:

- 뷰어 GUI 실행
- Windows 데스크톱 앱 빌드

#### UI / 창 관리

- `desktop_multi_window:^0.3.0`

역할:

- 데스크톱 창 관련 기능에 사용됩니다.

#### 파일 선택

- `file_selector:^1.1.0`

역할:

- 필요 시 로컬 파일 선택 UI에 사용됩니다.

#### HTTP 통신

- `http:^1.6.0`

역할:

- 서버 API 호출에 사용됩니다.
- 이벤트 로그, 소스 목록, 룰 설정, display name 저장, DB clear 요청 등에 사용됩니다.

#### 영상 재생

- `media_kit:^1.2.6`
- `media_kit_video:^2.0.1`
- `media_kit_libs_video:^1.0.7`

역할:

- 서버의 라이브 프리뷰/스트림 표시
- 이벤트 클립 재생

#### 개발용 패키지

- `flutter_test`
- `flutter_lints:^6.0.0`

역할:

- Flutter 테스트와 정적 규칙 확인에 사용됩니다.

### 날짜 필터 UI

이벤트 로그 날짜 구간 필터는 Flutter 기본 날짜 선택 UI를 사용할 수 있으므로 현재 기준으로 별도 외부 날짜 선택 패키지는 필요하지 않습니다.

### 뷰어에서 직접 필요하지 않은 항목

뷰어는 객체 탐지를 직접 하지 않으므로 아래 항목은 뷰어 전용 의존성이 아닙니다.

- PyTorch
- Ultralytics
- TensorRT
- OpenCV Python 패키지
- Python 가상환경

단, 같은 PC에서 서버나 클라이언트를 같이 실행한다면 해당 실행 단위의 의존성은 필요합니다.

## 5. 예제 프로젝트 의존성

`client_server_viewer_model` 폴더는 구조 이해용 예제 프로젝트입니다.

예제의 `requirements.txt`에는 아래 패키지가 있습니다.

- `ultralytics`
- `opencv-python`
- `numpy`
- `aiohttp`
- `PyQt5`
- `requests`

이 예제 의존성은 실제 `safety_monitor_server`, `safety_monitor_client`, `safety_monitor_viewer` 실행 기준 의존성과는 별도로 봅니다.

## 6. 배치파일 기준 설치 흐름

### 전체 환경 점검

```bat
check_environment.bat
```

확인 항목:

- 워크스페이스 경로 길이
- Git 설치 여부와 `core.longpaths`
- `.venv` 존재 여부
- Windows 개발자 모드
- Flutter SDK
- Visual Studio C++ Build Tools
- Windows SDK
- 서버/클라이언트/뷰어 프로젝트 파일 존재 여부

### 서버 의존성 설치

```bat
install_dependencies.bat server
```

수행 작업:

- `.venv` 생성
- `requirements-server.txt` 설치

### 클라이언트 의존성 설치

```bat
install_dependencies.bat client
```

수행 작업:

- Flutter Windows 빌드 환경 확인
- `.venv` 생성
- 루트 `requirements.txt` 설치
- `safety_monitor_client`에서 `flutter pub get`

### 뷰어 의존성 설치

```bat
install_dependencies.bat viewer
```

수행 작업:

- Flutter Windows 빌드 환경 확인
- `safety_monitor_viewer`에서 `flutter pub get`

### 전체 의존성 설치

```bat
install_dependencies.bat all
```

수행 작업:

- 서버 Python 의존성 설치
- 클라이언트 Python 의존성 설치
- 클라이언트 Flutter 의존성 설치
- 뷰어 Flutter 의존성 설치
