#!/bin/bash
#
# note this relies on *bash* not just sh (for example on freebsd)
# therefor /bin/bash has to exist

if [ $# -ne 3 ]
then
    echo "Usage: $0 <source-root> <install-root> <install-prefix>"
    exit 1
fi

source_root=$1
install_root=$2
install_prefix=$3

pushd $source_root > /dev/null

if [ `which gmake` ]; then MAKE=gmake; else MAKE=make; fi

## note!! we specify --libdir because we use libs and bigloo uses lib by default
./configure --prefix=$install_prefix --libdir=$install_prefix/libs --jvm=no && $MAKE

popd > /dev/null

install -m 755 -d $install_root
install -m 755 -d $install_root/$install_prefix/bin
install -m 755 -d $install_root/$install_prefix/libs/bigloo/2.9a

install -m 755 -s $source_root/bin/bigloo $install_root/$install_prefix/bin/bigloo
install -m 755  $source_root/runtime/Include/bigloo.h $install_root/$install_prefix/libs/bigloo/2.9a/bigloo.h
install -m 755  $source_root/lib/2.9a/bigloo.h $install_root/$install_prefix/libs/bigloo/2.9a/bigloo.h
install -m 755  $source_root/lib/2.9a/bigloo_config.h $install_root/$install_prefix/libs/bigloo/2.9a/bigloo_config.h
install -m 755  $source_root/lib/2.9a/bigloo.heap $install_root/$install_prefix/libs/bigloo/2.9a/bigloo.heap
install -m 755  -s $source_root/lib/2.9a/libbigloo_u-2.9a.so $install_root/$install_prefix/libs/bigloo/2.9a/libbigloo_u-2.9a.so
install -m 755  -s $source_root/gc-boehm/libgc.so $install_root/$install_prefix/libs/bigloo/2.9a/libbigloogc-2.9a.so
install -m 755  -s $source_root/lib/2.9a/libbigloogc-2.9a.so $install_root/$install_prefix/libs/bigloo/2.9a/libbigloogc-2.9a.so

install -m 755  $source_root/lib/2.9a/libbigloo_u-2.9a.a $install_root/$install_prefix/libs/bigloo/2.9a/libbigloo_u-2.9a.a
ranlib $install_root/$install_prefix/libs/bigloo/2.9a/libbigloo_u-2.9a.a

install -m 755  $source_root/lib/2.9a/libbigloogc-2.9a.a $install_root/$install_prefix/libs/bigloo/2.9a/libbigloogc-2.9a.a
ranlib $install_root/$install_prefix/libs/bigloo/2.9a/libbigloogc-2.9a.a

pushd $install_root/$install_prefix > /dev/null

ln -s bigloo/2.9a/libbigloo_u-2.9a.so $install_root/$install_prefix/libs/libbigloo_u-2.9a.so
ln -s bigloo/2.9a/libbigloogc-2.9a.so $install_root/$install_prefix/libs/libbigloogc-2.9a.so

popd > /dev/null

