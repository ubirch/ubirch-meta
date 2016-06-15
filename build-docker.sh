#!/bin/bash -x

ARM_CONTAINER_VERSION="latest"



function init() {

  DEPENDENCY_LABEL=`env | grep GO_DEPENDENCY_LABEL_ARM_BUILD_CONTAINER | cut -d= -f2 | sed 's/\s//g' | tr -d '\n'`


  if [ -z ${DEPENDENCY_LABEL} ]; then
    ARM_CONTAINER_VERSION="latest"
  else
    ARM_CONTAINER_VERSION="v${DEPENDENCY_LABEL}"
  fi


}

function build_software() {
  docker run --user `id -u`:`id -g` -e "HOME=/build" --workdir=/build/ubirch-meta --volume=${PWD}/..:/build  --entrypoint=/bin/bash ubirch/arm-build:${ARM_CONTAINER_VERSION} ./build.sh -a
  if [ $? -ne 0 ]; then
      echo "Docker build failed"
      exit 1
  fi
}

function link_repos() {
  REPOLIST="ubirch-kinetis-sdk ubirch-kinetis-sdk-package ubirch-wolfssl ubirch-wolfssl-package ubirch-arm-toolchain ubirch-board-crypto ubirch-board-firmware"

  for repo in ${REPOLIST} ; do
    #statements
    if [[ -d ../${repo} ]]; then
      #statements
      ln -s ../${repo} .
    fi
  done

}
case "$1" in
    build)
        init
        link_repos
        build_software
        ;;
    *)
        echo "Usage: $0 {build|publish}"
        exit 1
esac

exit 0
