#! /bin/sh
# do an out-of-source build for all configurations
if [ "$1" == "-u" ]; then export UPDATE="1"; shift; fi
if [ "$1" == "-a" ]
then
  BOARDS="ubirch-1 FRDM-K82F"
  BUILDS="RelWithDebInfo MinSizeRel Release Debug"
else
  BOARDS="ubirch-1"
  BUILDS="MinSizeRel"
fi
for BUILD_TYPE in $BUILDS
do
  for BOARD in $BOARDS
  do
    mkdir -p build/$BUILD_TYPE
    (cd build/$BUILD_TYPE; cmake ../.. -DBOARD=$BOARD -DCMAKE_BUILD_TYPE=$BUILD_TYPE; make)
    unset UPDATE
  done
done
