cmake_minimum_required(VERSION 3.12)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(READ "${CMAKE_SOURCE_DIR}/VERSION" VERSION_RAW)
string(STRIP ${VERSION_RAW} VERSION)

project(
  ipc-closewindowv2
  VERSION ${VERSION}
)

set(CMAKE_CXX_STANDARD 23)

add_compile_definitions(VERSION="${VERSION}")

find_package(PkgConfig REQUIRED)

include_directories(.)
file(GLOB_RECURSE SRCFILES "*.cpp")
add_library(ipc-closewindowv2 SHARED ${SRCFILES})
set_target_properties(ipc-closewindowv2 PROPERTIES PREFIX "")

pkg_check_modules(deps REQUIRED IMPORTED_TARGET
  hyprland
  pixman-1
  libdrm
)
target_link_libraries(ipc-closewindowv2 PRIVATE rt PkgConfig::deps)

install(TARGETS ipc-closewindowv2)


