#! /bin/sh
# do an out-of-source build for all configurations
if [ "$1" == "-u" ]; then export UPDATE="1"; shift; fi
if [ "$1" == "-a" ]
then BUILDS="RelWithDebInfo MinSizeRel Release Debug"
else BUILDS="MinSizeRel"
fi
for BUILD_TYPE in $BUILDS
do
  if [ ! -d build/$BUILD_TYPE ]
  then
    echo "Preparing build: $BUILD_TYPE"
    mkdir -p build/$BUILD_TYPE
    (cd build/$BUILD_TYPE; cmake ../.. -DCMAKE_BUILD_TYPE=$BUILD_TYPE)
  fi
  echo "Building: $BUILD_TYPE"
  (cd build/$BUILD_TYPE; make)
  unset UPDATE
done
