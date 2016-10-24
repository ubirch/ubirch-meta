#! /bin/bash
# do an out-of-source build for all configurations
BUILDS="MinSizeRel"
TARGET="all"
for arg in "$@"
do
  case $arg in
    -c|--clean)
      echo "Cleaning build directory and package registry."
      [ -d `dirname $0`/build ] && echo rm -r `dirname $0`/build
      [ -d $HOME/.cmake/packages/KinetisSDK ] && echo rm -vr $HOME/.cmake/packages/KinetisSDK
      [ -d $HOME/.cmake/packages/ubirch ] && echo rm -vr $HOME/.cmake/packages/ubirch
      [ -d $HOME/.cmake/packages/ubirch-crypto ] && echo rm -vr $HOME/.cmake/packages/ubirch-crypto
      [ -d $HOME/.cmake/packages/wolfSSL ] && echo rm -vr $HOME/.cmake/packages/wolfSSL
      echo -n "Execute remove commands? (type 'yes') "
      read yesno
      if [ "$yesno" == "yes" ]; then
        [ -d `dirname $0`/build ] && rm -r `dirname $0`/build
        [ -d $HOME/.cmake/packages/KinetisSDK ] && rm -vr $HOME/.cmake/packages/KinetisSDK
        [ -d $HOME/.cmake/packages/ubirch ] && rm -vr $HOME/.cmake/packages/ubirch
        [ -d $HOME/.cmake/packages/ubirch-crypto ] && rm -vr $HOME/.cmake/packages/ubirch-crypto
        [ -d $HOME/.cmake/packages/wolfSSL ] &&  rm -vr $HOME/.cmake/packages/wolfSSL
      else
        echo "Exiting."
        exit
      fi
      ;;
    -u|--update)
      (cd `dirname $0`; for i in *; do [ -d $i ] && (cd $i; pwd; git pull); done)
      shift
      ;;
    -a)
      BUILDS="RelWithDebInfo MinSizeRel Release Debug"
      shift
      ;;
    -d)
      TARGET="all-doc"
      shift
      ;;
    *)
      ;;
  esac
done

for BUILD_TYPE in $BUILDS
do
  if [ ! -d build/$BUILD_TYPE ]
  then
    echo "Preparing build: $BUILD_TYPE"
    mkdir -p build/$BUILD_TYPE
    (cd build/$BUILD_TYPE; cmake ../.. -DCMAKE_BUILD_TYPE=$BUILD_TYPE)
  fi
  echo "Building: $BUILD_TYPE"
  (cd build/$BUILD_TYPE; make clean $TARGET)
done
