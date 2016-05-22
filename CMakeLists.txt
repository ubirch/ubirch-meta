cmake_minimum_required(VERSION 3.0.2)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "MinSizeRel")
endif ()

set(MCUS "MK82F25615") # later add "MKL82Z7"
set(BOARDS "ubirch1r02" "FRDM-K82F") # later add "FRDM-KL82Z"

project(ubirch-meta NONE)
include(ExternalProject)

find_package(Git)
if (NOT GIT_FOUND)
  message(FATAL_ERROR "No git executable found!")
endif ()

function(update dir url branch)
  if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/.git)
    message("Cloning ${url}")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} clone ${url} ${dir}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE OUTPUT
    )
    message("${OUTPUT}")
  endif ()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} checkout ${branch}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
    OUTPUT_VARIABLE OUTPUT
  )
  message("${OUTPUT}")
  if ($ENV{UPDATE})
    message("Updating ${url}")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} pull
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
      OUTPUT_VARIABLE OUTPUT
    )
    message("${OUTPUT}")
  endif ()
endfunction()

# Update or clone repositories

# Toolchain (download only)
update(ubirch-arm-toolchain git@gitlab.com:ubirch/ubirch-arm-toolchain.git master)
# Kinetis SDK (download only)
update(ubirch-kinetis-sdk git@gitlab.com:ubirch/ubirch-kinetis-sdk.git master)
# WolfSSL (download only)
update(ubirch-wolfssl git@gitlab.com:ubirch/ubirch-wolfssl kinetis-sdk-2.0)
# Kinetis SDK Package
update(ubirch-kinetis-sdk-package git@gitlab.com:ubirch/ubirch-kinetis-sdk-package.git master)
# WolfSSL (wolfcrypt) Package
update(ubirch-wolfssl-package git@gitlab.com:ubirch/ubirch-wolfssl-package master)
# ubirch#1 Board Firmware Package
update(ubirch-board-firmware git@gitlab.com:ubirch/ubirch-board-firmware master)

# Downloaded repositories added as dependencies

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
get_filename_component(SDK_ROOT "${SOURCE_DIR}" REALPATH)

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

# Build BOARD dependend packages
foreach (BOARD ${BOARDS})
  # we set the used MCU based on the board
  if (BOARD MATCHES "ubirch1|FRDM-K82F")
    set(MCU "MK82F25615")
    set(SDK "${SDK_ROOT}/SDK_2.0_MK82FN256xxx15")
  elseif (BOARD MATCHES "FRDM-KL82Z")
    set(MCU "MKL82Z7")
    set(SDK "${SDK_ROOT}/SDK_1.3_MKL82Z")
  endif ()

  # create kinetis sdk package (only once for each MCU)
  if (NOT TARGET ubirch-kinetis-sdk-package-${MCU})
    ExternalProject_Add(ubirch-kinetis-sdk-package-${MCU}
      DEPENDS ubirch-arm-toolchain ubirch-kinetis-sdk
      BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/ksdk-${MCU}
      SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-kinetis-sdk-package
      CMAKE_ARGS
      -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DSDK_ROOT=${SDK}
      -DMCU=${MCU}
      DOWNLOAD_COMMAND ""
      BUILD_COMMAND "${CMAKE_MAKE_PROGRAM}"
      INSTALL_COMMAND ""
      UPDATE_DISCONNECTED ${DO_UPDATE}
      )
  endif ()

  # create wolfssl package (only once for each MCU)
  if (NOT TARGET ubirch-wolfssl-package-${MCU})
    ExternalProject_Add(ubirch-wolfssl-package-${MCU}
      DEPENDS ubirch-kinetis-sdk-package-${MCU} ubirch-wolfssl
      BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/wssl-${MCU}
      SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-wolfssl-package
      CMAKE_ARGS
      -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DMCU=${MCU}
      -DWOLFSSL_ROOT=${WOLFSSL_ROOT}
      DOWNLOAD_COMMAND ""
      BUILD_COMMAND "${CMAKE_MAKE_PROGRAM}"
      INSTALL_COMMAND ""
      UPDATE_DISCONNECTED ${DO_UPDATE}
      )
  endif ()

  ExternalProject_Add(ubirch-board-firmware-${BOARD}
    DEPENDS ubirch-kinetis-sdk-package-${MCU} ubirch-wolfssl-package-${MCU}
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/fw-${BOARD}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-board-firmware
    CMAKE_ARGS
    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DBOARD=${BOARD}
    DOWNLOAD_COMMAND ""
#    BUILD_COMMAND "${CMAKE_MAKE_PROGRAM}"
    INSTALL_COMMAND ""
    UPDATE_DISCONNECTED ${DO_UPDATE}
    )
endforeach ()
