@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0"
if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"
set "PROJECT_DIR=%ROOT_DIR%\safety_monitor_viewer"
set "PROJECT_REL=safety_monitor_viewer"
set "PROJECT_NAME=Viewer"
set "INSTALL_TARGET=viewer"
set "BUILD_LINK=C:\smw_build_viewer"
set "LOCAL_FLUTTER=%ROOT_DIR%\flutter\bin\flutter.bat"
set "FLUTTER_CMD=flutter"
set "PAUSE_ON_EXIT=1"
if /I "%~1"=="/nopause" set "PAUSE_ON_EXIT=0"
if /I "%~1"=="--no-pause" set "PAUSE_ON_EXIT=0"

call :check_workspace_path
if errorlevel 1 goto :fail
call :check_developer_mode
if errorlevel 1 goto :fail
call :find_flutter
if errorlevel 1 goto :fail
call :prepare_windows_build_environment
if errorlevel 1 goto :fail

if not exist "%PROJECT_DIR%\pubspec.yaml" (
  echo %PROJECT_NAME% project not found:
  echo   %PROJECT_DIR%\pubspec.yaml
  goto :fail
)

call :prepare_short_link
if errorlevel 1 goto :fail
call :build_project "%BUILD_LINK%\%PROJECT_REL%" "%PROJECT_NAME%"
set "BUILD_RESULT=%ERRORLEVEL%"
call :release_short_link
if not "%BUILD_RESULT%"=="0" goto :fail

echo %PROJECT_NAME% build finished.
if "%PAUSE_ON_EXIT%"=="1" pause
exit /b 0

:build_project
set "SHORT_PROJECT_DIR=%~1"
set "SHORT_PROJECT_NAME=%~2"
if not exist "%SHORT_PROJECT_DIR%\pubspec.yaml" (
  echo %SHORT_PROJECT_NAME% project not found through short build path:
  echo   %SHORT_PROJECT_DIR%\pubspec.yaml
  exit /b 1
)

echo Building %SHORT_PROJECT_NAME% through short path %SHORT_PROJECT_DIR%
pushd "%SHORT_PROJECT_DIR%"
call "%FLUTTER_CMD%" clean
if errorlevel 1 (
  popd
  exit /b 1
)

if not exist "windows\flutter\CMakeLists.txt" (
  echo Regenerating missing Windows Flutter files...
  call "%FLUTTER_CMD%" create --platforms=windows .
  if errorlevel 1 (
    popd
    exit /b 1
  )
)

call "%FLUTTER_CMD%" pub get
if errorlevel 1 (
  popd
  exit /b 1
)

call "%FLUTTER_CMD%" config --enable-windows-desktop
if errorlevel 1 (
  popd
  exit /b 1
)

call "%FLUTTER_CMD%" build windows
set "RESULT=%ERRORLEVEL%"
popd
exit /b %RESULT%

:check_workspace_path
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "'%ROOT_DIR%'.Length"`) do set "ROOT_LEN=%%i"
echo Workspace root: %ROOT_DIR%
echo Path length: %ROOT_LEN%
if %ROOT_LEN% GEQ 80 (
  echo This path is too long. Move the repository near a drive root, e.g. C:\hiyoung_team_github\safety_monitor_workspace or D:\safety_monitor_workspace.
  exit /b 1
)
exit /b 0

:prepare_short_link
call :release_short_link
if exist "%BUILD_LINK%" (
  echo Build link path still exists and could not be removed:
  echo   %BUILD_LINK%
  exit /b 1
)
cmd /c mklink /J "%BUILD_LINK%" "%ROOT_DIR%" > nul
if errorlevel 1 (
  echo Could not create build junction:
  echo   %BUILD_LINK% =^> %ROOT_DIR%
  exit /b 1
)
echo Using short build path %BUILD_LINK% mapped to %ROOT_DIR%
exit /b 0

:release_short_link
if exist "%BUILD_LINK%" (
  cmd /c rmdir "%BUILD_LINK%" > nul 2>&1
)
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
  exit /b 0
)
where flutter > nul 2>&1
if errorlevel 1 (
  echo Flutter SDK not found. Put Flutter at:
  echo   %ROOT_DIR%\flutter
  echo or add flutter to PATH.
  exit /b 1
)
set "FLUTTER_CMD=flutter"
exit /b 0

:prepare_windows_build_environment
git -C "%ROOT_DIR%" config core.longpaths true > nul 2>&1
call :ensure_windows_build_tools
exit /b %ERRORLEVEL%

:ensure_windows_build_tools
set "VSWHERE_EXE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VS_NATIVE_READY="
set "SDK_READY="
if exist "%VSWHERE_EXE%" (
  for /f "usebackq delims=" %%i in (`"%VSWHERE_EXE%" -products * -requires Microsoft.VisualStudio.Workload.NativeDesktop Microsoft.VisualStudio.Component.VC.Tools.x86.x64 Microsoft.VisualStudio.Component.VC.CMake.Project -property installationPath`) do set "VS_NATIVE_READY=%%i"
)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "$roots=@('C:\Program Files (x86)\Windows Kits\10\Include','C:\Program Files\Windows Kits\10\Include'); foreach($root in $roots){ if(Test-Path $root){ $dirs=Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending; if($dirs){ $dirs[0].FullName; break } } }"`) do set "SDK_READY=%%i"
if defined VS_NATIVE_READY if defined SDK_READY exit /b 0
echo Windows C++ build tools are missing.
echo Install Visual Studio Build Tools with "Desktop development with C++", MSVC tools, Windows 10/11 SDK, and CMake tools.
exit /b 1

:fail
call :release_short_link
echo %PROJECT_NAME% build failed.
if "%PAUSE_ON_EXIT%"=="1" pause
exit /b 1

