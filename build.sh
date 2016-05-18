#! /bin/sh
# do an out-of-source build for all configurations
if [ "$1" == "-u" ]; then UPDATE="1"; shift; fi
if [ "$1" == "-a" ]
then BUILDS="RelWithDebInfo MinSizeRel Release Debug"
else BUILDS=MinSizeRel
fi
for BUILD_TYPE in $BUILDS
do
  if [ -d build/$BUILD_TYPE ]
  then
    (cd build/$BUILD_TYPE; make)
  else
    mkdir -p build/$BUILD_TYPE
    (cd build/$BUILD_TYPE; cmake ../.. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && make)
  fi
done
