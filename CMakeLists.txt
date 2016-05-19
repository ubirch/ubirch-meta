cmake_minimum_required(VERSION 3.0.2)
include(ExternalProject)
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "MinSizeRel")
endif ()
set(MCU "MK82F25615")
set(SDK "SDK_2.0_MK82FN256xxx15")

find_package(Git)
if (NOT GIT_FOUND)
  message(FATAL_ERROR "No git executable found!")
endif ()

macro(update dir url branch)
  if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/.git)
    message("Cloning ${url}")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} clone --branch ${branch} --single-branch --depth 1 ${url} ${dir}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE OUTPUT
    )
    message("${OUTPUT}")
  endif()
  if($ENV{UPDATE})
    message("Updating ${url}")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} pull
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
      OUTPUT_VARIABLE OUTPUT
    )
    message("${OUTPUT}")
  endif()
endmacro()

# Toolchain (download only)
update(ubirch-arm-toolchain git@gitlab.com:ubirch/ubirch-arm-toolchain.git master)

ExternalProject_Add(ubirch-arm-toolchain
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-arm-toolchain
  DOWNLOAD_COMMAND ""
  CMAKE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  CONFIGURE_COMMAND ""
  UPDATE_DISCONNECTED ${DO_UPDATE}
  )
ExternalProject_Get_Property(ubirch-arm-toolchain SOURCE_DIR)
get_filename_component(TOOLCHAIN_FILE "${SOURCE_DIR}/cmake/ubirch-arm-gcc-toolchain.cmake" REALPATH)

# Kinetis SDK (download only)
update(ubirch-kinetis-sdk git@gitlab.com:ubirch/ubirch-kinetis-sdk.git master)

ExternalProject_Add(ubirch-kinetis-sdk
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-kinetis-sdk
  DOWNLOAD_COMMAND ""
  CMAKE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  CONFIGURE_COMMAND ""
  UPDATE_DISCONNECTED ${DO_UPDATE}
  )
ExternalProject_Get_Property(ubirch-kinetis-sdk SOURCE_DIR)
get_filename_component(SDK_ROOT "${SOURCE_DIR}/${SDK}" REALPATH)

# WolfSSL (download only)
update(ubirch-wolfssl git@gitlab.com:ubirch/ubirch-wolfssl kinetis-sdk-2.0)

ExternalProject_Add(ubirch-wolfssl
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-wolfssl
  DOWNLOAD_COMMAND ""
  CMAKE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  CONFIGURE_COMMAND ""
  UPDATE_DISCONNECTED ${DO_UPDATE}
  )
ExternalProject_Get_Property(ubirch-wolfssl SOURCE_DIR)
get_filename_component(WOLFSSL_ROOT "${SOURCE_DIR}" REALPATH)

# Kinetis SDK Package
update(ubirch-kinetis-sdk-package git@gitlab.com:ubirch/ubirch-kinetis-sdk-package.git master)

ExternalProject_Add(ubirch-kinetis-sdk-package
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-kinetis-sdk-package
  DEPENDS ubirch-arm-toolchain ubirch-kinetis-sdk
  CMAKE_ARGS
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
  -DSDK_ROOT=${SDK_ROOT}
  -DMCU=${MCU}
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  DOWNLOAD_COMMAND ""
  INSTALL_COMMAND ""
  UPDATE_DISCONNECTED ${DO_UPDATE}
  )

# WolfSSL (wolfcrypt) Package
update(ubirch-wolfssl-package git@gitlab.com:ubirch/ubirch-wolfssl-package master)

ExternalProject_Add(ubirch-wolfssl-package
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-wolfssl-package
  DEPENDS ubirch-kinetis-sdk-package ubirch-wolfssl
  CMAKE_ARGS
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
  -DMCU=${MCU}
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DWOLFSSL_ROOT=${WOLFSSL_ROOT}
  DOWNLOAD_COMMAND ""
  INSTALL_COMMAND ""
  UPDATE_DISCONNECTED ${DO_UPDATE}
  )

# ubirch#1 Board Firmware Package
update(ubirch-board-firmware git@gitlab.com:ubirch/ubirch-board-firmware master)

ExternalProject_Add(ubirch-board-firmware
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-board-firmware
  DEPENDS ubirch-kinetis-sdk-package ubirch-wolfssl-package
  CMAKE_ARGS
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
  -DMCU=${MCU}
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  DOWNLOAD_COMMAND ""
  INSTALL_COMMAND ""
  UPDATE_DISCONNECTED ${DO_UPDATE}
  )

