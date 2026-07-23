@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0"
if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"
set "VENV_DIR=%ROOT_DIR%\.venv"
set "PYTHON_EXE=%VENV_DIR%\Scripts\python.exe"
set "LOCAL_FLUTTER=%ROOT_DIR%\flutter\bin\flutter.bat"
set "FLUTTER_CMD=flutter"
set "MODE=%~1"

if "%MODE%"=="" set "MODE=all"
if /I not "%MODE%"=="server" if /I not "%MODE%"=="client" if /I not "%MODE%"=="viewer" if /I not "%MODE%"=="all" (
  echo Usage: install_dependencies.bat [server^|client^|viewer^|all]
  exit /b 1
)

call :check_workspace_path
if errorlevel 1 exit /b 1

if /I "%MODE%"=="client" (
  call :check_flutter_windows_dependencies
  if errorlevel 1 exit /b 1
)
if /I "%MODE%"=="viewer" (
  call :check_flutter_windows_dependencies
  if errorlevel 1 exit /b 1
)
if /I "%MODE%"=="all" (
  call :check_flutter_windows_dependencies
  if errorlevel 1 exit /b 1
)

if not exist "%VENV_DIR%" (
  call :find_bootstrap_python
  if errorlevel 1 exit /b 1
  echo Creating virtual environment at %VENV_DIR%
  "%BOOTSTRAP_PYTHON%" -m venv "%VENV_DIR%"
  if errorlevel 1 exit /b 1
)

if not exist "%PYTHON_EXE%" (
  echo Python executable was not found in %VENV_DIR%.
  echo Delete .venv and run this script again.
  exit /b 1
)

"%PYTHON_EXE%" -m pip install --upgrade pip
if errorlevel 1 exit /b 1

if /I "%MODE%"=="server" call :ensure_server
if /I "%MODE%"=="client" (
  call :ensure_client
  if errorlevel 1 exit /b 1
  call :ensure_flutter_project "%ROOT_DIR%\safety_monitor_client" "Client"
)
if /I "%MODE%"=="viewer" call :ensure_flutter_project "%ROOT_DIR%\safety_monitor_viewer" "Viewer"
if /I "%MODE%"=="all" (
  call :ensure_server
  if errorlevel 1 exit /b 1
  call :ensure_client
  if errorlevel 1 exit /b 1
  call :ensure_flutter_project "%ROOT_DIR%\safety_monitor_client" "Client"
  if errorlevel 1 exit /b 1
  call :ensure_flutter_project "%ROOT_DIR%\safety_monitor_viewer" "Viewer"
)
if errorlevel 1 exit /b 1

echo.
echo Dependency installation finished for %MODE%.
exit /b 0

:check_workspace_path
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "'%ROOT_DIR%'.Length"`) do set "ROOT_LEN=%%i"
echo Workspace root: %ROOT_DIR%
echo Path length: %ROOT_LEN%
if %ROOT_LEN% GEQ 80 (
  echo ERROR: workspace path is too long for stable Flutter Windows builds.
  echo Move the repository near a drive root, for example:
  echo   C:\safety_monitor_workspace
  echo   D:\safety_monitor_workspace
  exit /b 1
)
exit /b 0

:find_bootstrap_python
set "BOOTSTRAP_PYTHON="
where py > nul 2>&1
if not errorlevel 1 (
  py -3.12 --version > nul 2>&1
  if not errorlevel 1 set "BOOTSTRAP_PYTHON=py -3.12"
)
if not defined BOOTSTRAP_PYTHON (
  where python > nul 2>&1
  if not errorlevel 1 set "BOOTSTRAP_PYTHON=python"
)
if not defined BOOTSTRAP_PYTHON (
  echo Python was not found. Install Python 3.12 and add it to PATH.
  exit /b 1
)
echo Bootstrap Python: %BOOTSTRAP_PYTHON%
exit /b 0

:ensure_server
echo Installing server dependencies...
"%PYTHON_EXE%" -m pip install -r "%ROOT_DIR%\requirements-server.txt"
if errorlevel 1 exit /b 1
exit /b 0

:ensure_client
echo Installing client embedded backend dependencies...
"%PYTHON_EXE%" -m pip install -r "%ROOT_DIR%\requirements.txt"
if errorlevel 1 exit /b 1
exit /b 0

:ensure_flutter_project
set "FLUTTER_PROJECT_DIR=%~1"
set "FLUTTER_PROJECT_NAME=%~2"
if not exist "%FLUTTER_PROJECT_DIR%\pubspec.yaml" (
  echo %FLUTTER_PROJECT_NAME% Flutter project not found:
  echo   %FLUTTER_PROJECT_DIR%\pubspec.yaml
  exit /b 1
)
echo Installing %FLUTTER_PROJECT_NAME% Flutter dependencies...
pushd "%FLUTTER_PROJECT_DIR%"
call "%FLUTTER_CMD%" config --enable-windows-desktop
if errorlevel 1 (
  popd
  exit /b 1
)
call "%FLUTTER_CMD%" pub get
if errorlevel 1 (
  popd
  exit /b 1
)
popd
exit /b 0

:check_flutter_windows_dependencies
echo Checking Flutter Windows build dependencies...
call :check_developer_mode
if errorlevel 1 exit /b 1
call :find_flutter
if errorlevel 1 exit /b 1
call :ensure_windows_build_tools
if errorlevel 1 exit /b 1
exit /b 0

:check_developer_mode
set "DEV_MODE_VALUE="
for /f "tokens=3" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense 2^>nul ^| find /I "AllowDevelopmentWithoutDevLicense"') do set "DEV_MODE_VALUE=%%i"
if /I "%DEV_MODE_VALUE%"=="0x1" (
  echo Windows Developer Mode: enabled
  exit /b 0
)
echo Windows Developer Mode: disabled or not configured.
echo Enable it before Flutter Windows builds:
echo   Settings ^> System ^> For developers ^> Developer Mode ^> On
echo Or run this in an elevated PowerShell/cmd session:
echo   reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v AllowDevelopmentWithoutDevLicense /d 1
exit /b 1

:find_flutter
if exist "%LOCAL_FLUTTER%" (
  set "FLUTTER_CMD=%LOCAL_FLUTTER%"
  call "%LOCAL_FLUTTER%" --version > nul 2>&1
  if errorlevel 1 (
    echo Flutter SDK was found but could not run:
    echo   %LOCAL_FLUTTER%
    exit /b 1
  )
  echo Flutter SDK: local workspace SDK found
  exit /b 0
)
where flutter > nul 2>&1
if errorlevel 1 (
  echo Flutter SDK not found.
  echo Install Flutter for Windows and either:
  echo   1. Put it at %ROOT_DIR%\flutter
  echo   2. Or add flutter\bin to PATH
  exit /b 1
)
flutter --version > nul 2>&1
if errorlevel 1 (
  echo Flutter SDK was found in PATH but could not run flutter --version.
  exit /b 1
)
set "FLUTTER_CMD=flutter"
echo Flutter SDK: PATH flutter found
exit /b 0

:ensure_windows_build_tools
set "VSWHERE_EXE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VS_NATIVE_READY="
set "SDK_READY="
if exist "%VSWHERE_EXE%" (
  for /f "usebackq delims=" %%i in (`"%VSWHERE_EXE%" -products * -requires Microsoft.VisualStudio.Workload.NativeDesktop Microsoft.VisualStudio.Component.VC.Tools.x86.x64 Microsoft.VisualStudio.Component.VC.CMake.Project -property installationPath`) do set "VS_NATIVE_READY=%%i"
)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "$roots=@('C:\Program Files (x86)\Windows Kits\10\Include','C:\Program Files\Windows Kits\10\Include'); foreach($root in $roots){ if(Test-Path $root){ $dirs=Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending; if($dirs){ $dirs[0].FullName; break } } }"`) do set "SDK_READY=%%i"
if defined VS_NATIVE_READY if defined SDK_READY (
  echo Visual Studio C++ tools: found
  echo Windows SDK: found
  exit /b 0
)
echo Windows C++ build tools are missing.
echo Install Visual Studio Build Tools with these components:
echo   - Desktop development with C++
echo   - MSVC v143 or newer C++ x64/x86 build tools
echo   - Windows 10/11 SDK
echo   - CMake tools for Windows
exit /b 1