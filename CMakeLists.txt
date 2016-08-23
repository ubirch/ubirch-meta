cmake_minimum_required(VERSION 3.0.2)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "MinSizeRel")
endif ()

set(MCUS "MK82F25615" "MKL82Z7") # later add "MKL82Z7"
set(BOARDS "ubirch1r03k01" "ubirch1r02" "FRDM-K82F" "FRDM-KL82Z")

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
set(UBIRCH_RELEASE_TAG "master" CACHE STRING "tag for the current release")

# Toolchain (download only)
update(ubirch-arm-toolchain git@github.com:ubirch/ubirch-arm-toolchain.git ${UBIRCH_RELEASE_TAG})
# Kinetis SDK (download only)
update(ubirch-kinetis-sdk git@github.com:ubirch/ubirch-kinetis-sdk.git ${UBIRCH_RELEASE_TAG})
# WolfSSL (w/ hw crypto by NXP, download only)
update(ubirch-wolfssl-nxp git@github.com:ubirch/ubirch-wolfssl-nxp ${UBIRCH_RELEASE_TAG})
# WolfSSL (download only)
update(ubirch-wolfssl git@github.com:ubirch/ubirch-wolfssl kinetis-sdk-2.0)
# Kinetis SDK Package
update(ubirch-kinetis-sdk-package git@github.com:ubirch/ubirch-kinetis-sdk-package.git ${UBIRCH_RELEASE_TAG})
# WolfSSL (wolfcrypt) Package
update(ubirch-wolfssl-package git@github.com:ubirch/ubirch-wolfssl-package ${UBIRCH_RELEASE_TAG})
# ubirch#1 Board Firmware Package
update(ubirch-board-firmware git@github.com:ubirch/ubirch-board-firmware ${UBIRCH_RELEASE_TAG})
# ubirch#1 Board Crypto Package
update(ubirch-board-crypto git@github.com:ubirch/ubirch-board-crypto ${UBIRCH_RELEASE_TAG})

# Downloaded repositories added as dependencies

ExternalProject_Add(ubirch-arm-toolchain
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-arm-toolchain
  DOWNLOAD_COMMAND ""
  CMAKE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  CONFIGURE_COMMAND ""
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
  )
ExternalProject_Get_Property(ubirch-kinetis-sdk SOURCE_DIR)
get_filename_component(SDK_ROOT "${SOURCE_DIR}" REALPATH)

find_path(WOLFSSL_PKG NAMES middleware wolfssl PATHS ubirch-wolfssl-nxp ubirch-wolfssl wolfssl)
message(STATUS "using ${WOLFSSL_PKG} as wolfSSL implementation")
ExternalProject_Add(ubirch-wolfssl
  SOURCE_DIR ${WOLFSSL_PKG}
  DOWNLOAD_COMMAND ""
  CMAKE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  CONFIGURE_COMMAND ""
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
    set(SDK "${SDK_ROOT}/SDK_2.0_MKL82Z128xxx7")
  endif ()

  # create kinetis sdk package (only once for each MCU)
  if (NOT TARGET ubirch-kinetis-sdk-package-${MCU})
    ExternalProject_Add(ubirch-kinetis-sdk-package-${MCU}
      DEPENDS ubirch-arm-toolchain ubirch-kinetis-sdk
      BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${MCU}/ksdk
      SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-kinetis-sdk-package
      CMAKE_ARGS
      -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DSDK_ROOT=${SDK}
      -DMCU=${MCU}
      DOWNLOAD_COMMAND ""
      INSTALL_COMMAND ""
      )
  endif ()

  # create wolfssl package (only once for each MCU)
  if (NOT TARGET ubirch-wolfssl-package-${MCU})
    ExternalProject_Add(ubirch-wolfssl-package-${MCU}
      DEPENDS ubirch-kinetis-sdk-package-${MCU} ubirch-wolfssl
      BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${MCU}/wssl
      SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-wolfssl-package
      CMAKE_ARGS
      -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DMCU=${MCU}
      -DWOLFSSL_ROOT=${WOLFSSL_ROOT}
      DOWNLOAD_COMMAND ""
      INSTALL_COMMAND ""
      )
  endif ()

  ExternalProject_Add(ubirch-board-firmware-${BOARD}
    DEPENDS ubirch-kinetis-sdk-package-${MCU}
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${BOARD}/fw
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-board-firmware
    CMAKE_ARGS
    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DBOARD=${BOARD}
    DOWNLOAD_COMMAND ""
    INSTALL_COMMAND ""
    )

  ExternalProject_Add(ubirch-crypto-${BOARD}
    DEPENDS ubirch-board-firmware-${BOARD} ubirch-wolfssl-package-${MCU}
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${BOARD}/crypto
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-board-crypto
    CMAKE_ARGS
    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DBOARD=${BOARD}
    DOWNLOAD_COMMAND ""
    INSTALL_COMMAND ""
    )
endforeach ()

# Generate Documentation for firmware and board
find_package(Doxygen)
if (DOXYGEN_FOUND)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/doxygen/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
  add_custom_target(all-doc ALL
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating API documentation with Doxygen" VERBATIM
    )
  add_custom_command(TARGET all-doc
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-board-firmware/board/ubirch1r02/ubirch1r02-back.jpg ${CMAKE_CURRENT_SOURCE_DIR}/docs/html
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/ubirch-board-firmware/board/ubirch1r02/ubirch1r02-front.jpg ${CMAKE_CURRENT_SOURCE_DIR}/docs/html
    )
endif ()
