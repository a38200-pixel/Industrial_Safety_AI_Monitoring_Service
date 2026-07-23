# Install script for directory: C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/windows

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "$<TARGET_FILE_DIR:safety_ai_monitor_ui>")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/flutter/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/desktop_multi_window/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/file_selector_windows/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_libs_windows_video/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_video/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/safety_ai_monitor_ui.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug" TYPE EXECUTABLE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/safety_ai_monitor_ui.exe")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/safety_ai_monitor_ui.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile" TYPE EXECUTABLE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/safety_ai_monitor_ui.exe")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/safety_ai_monitor_ui.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release" TYPE EXECUTABLE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/safety_ai_monitor_ui.exe")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/data" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/windows/flutter/ephemeral/icudtl.dat")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/data" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/windows/flutter/ephemeral/icudtl.dat")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/data" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/windows/flutter/ephemeral/icudtl.dat")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/windows/flutter/ephemeral/flutter_windows.dll")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/windows/flutter/ephemeral/flutter_windows.dll")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/windows/flutter/ephemeral/flutter_windows.dll")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/desktop_multi_window_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/file_selector_windows_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/media_kit_libs_windows_video_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/libmpv-2.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/d3dcompiler_47.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/libEGL.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/libGLESv2.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/vk_swiftshader.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/vulkan-1.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/zlib.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/media_kit_video_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug" TYPE FILE FILES
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/desktop_multi_window/Debug/desktop_multi_window_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/file_selector_windows/Debug/file_selector_windows_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_libs_windows_video/Debug/media_kit_libs_windows_video_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/libmpv/libmpv-2.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/d3dcompiler_47.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/libEGL.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/libGLESv2.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/vk_swiftshader.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/vulkan-1.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/zlib.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_video/Debug/media_kit_video_plugin.dll"
      )
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/desktop_multi_window_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/file_selector_windows_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/media_kit_libs_windows_video_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/libmpv-2.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/d3dcompiler_47.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/libEGL.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/libGLESv2.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/vk_swiftshader.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/vulkan-1.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/zlib.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/media_kit_video_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile" TYPE FILE FILES
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/desktop_multi_window/Profile/desktop_multi_window_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/file_selector_windows/Profile/file_selector_windows_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_libs_windows_video/Profile/media_kit_libs_windows_video_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/libmpv/libmpv-2.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/d3dcompiler_47.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/libEGL.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/libGLESv2.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/vk_swiftshader.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/vulkan-1.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/zlib.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_video/Profile/media_kit_video_plugin.dll"
      )
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/desktop_multi_window_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/file_selector_windows_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/media_kit_libs_windows_video_plugin.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/libmpv-2.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/d3dcompiler_47.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/libEGL.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/libGLESv2.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/vk_swiftshader.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/vulkan-1.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/zlib.dll;C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/media_kit_video_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release" TYPE FILE FILES
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/desktop_multi_window/Release/desktop_multi_window_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/file_selector_windows/Release/file_selector_windows_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_libs_windows_video/Release/media_kit_libs_windows_video_plugin.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/libmpv/libmpv-2.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/d3dcompiler_47.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/libEGL.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/libGLESv2.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/vk_swiftshader.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/vulkan-1.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/ANGLE/zlib.dll"
      "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/plugins/media_kit_video/Release/media_kit_video_plugin.dll"
      )
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug" TYPE DIRECTORY FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/native_assets/windows/")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile" TYPE DIRECTORY FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/native_assets/windows/")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release" TYPE DIRECTORY FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/native_assets/windows/")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    
  file(REMOVE_RECURSE "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/data/flutter_assets")
  
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    
  file(REMOVE_RECURSE "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/data/flutter_assets")
  
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    
  file(REMOVE_RECURSE "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/data/flutter_assets")
  
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Debug/data" TYPE DIRECTORY FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build//flutter_assets")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/data" TYPE DIRECTORY FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build//flutter_assets")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/data" TYPE DIRECTORY FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build//flutter_assets")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Profile/data" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/app.so")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/runner/Release/data" TYPE FILE FILES "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/app.so")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "C:/Users/user/Desktop/hiyoung_team_github/safety_monitor_workspace/safety_ai_monitor_ui/build/windows/x64/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
