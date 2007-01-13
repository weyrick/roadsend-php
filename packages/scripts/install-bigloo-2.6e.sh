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

./configure --prefix=$install_prefix --jvm=no && $MAKE

popd > /dev/null

install -m 755 -d $install_root
install -m 755 -d $install_root/$install_prefix/bin
install -m 755 -d $install_root/$install_prefix/lib/bigloo/2.6e
#install -m 755 -d $install_root/$install_prefix/lib/bigloo/2.6e/bmem

install -m 755 -s $source_root/bin/bigloo $install_root/$install_prefix/bin/bigloo
install -m 755  $source_root/runtime/Include/bigloo.h $install_root/$install_prefix/lib/bigloo/2.6e/bigloo.h
install -m 755  $source_root/lib/2.6e/bigloo.h $install_root/$install_prefix/lib/bigloo/2.6e/bigloo.h
install -m 755  $source_root/lib/2.6e/bigloo_config.h $install_root/$install_prefix/lib/bigloo/2.6e/bigloo_config.h
install -m 755  $source_root/lib/2.6e/bigloo.heap $install_root/$install_prefix/lib/bigloo/2.6e/bigloo.heap
#install -m 755  -s $source_root/lib/2.6e/bmem/bmem.so $install_root/$install_prefix/lib/bigloo/2.6e/bmem/bmem.so
install -m 755  -s $source_root/lib/2.6e/libbigloo_u-2.6e.so $install_root/$install_prefix/lib/bigloo/2.6e/libbigloo_u-2.6e.so
install -m 755  -s $source_root/gc-boehm/libgc.so $install_root/$install_prefix/lib/bigloo/2.6e/libbigloogc-2.6e.so
install -m 755  -s $source_root/lib/2.6e/libbigloogc-2.6e.so $install_root/$install_prefix/lib/bigloo/2.6e/libbigloogc-2.6e.so

install -m 755  $source_root/lib/2.6e/libbigloo_u-2.6e.a $install_root/$install_prefix/lib/bigloo/2.6e/libbigloo_u-2.6e.a
ranlib $install_root/$install_prefix/lib/bigloo/2.6e/libbigloo_u-2.6e.a

install -m 755  $source_root/lib/2.6e/libbigloogc-2.6e.a $install_root/$install_prefix/lib/bigloo/2.6e/libbigloogc-2.6e.a
ranlib $install_root/$install_prefix/lib/bigloo/2.6e/libbigloogc-2.6e.a

pushd $install_root/$install_prefix > /dev/null

ln -s bigloo/2.6e/libbigloo_u-2.6e.so $install_root/$install_prefix/lib/libbigloo_u-2.6e.so
ln -s bigloo/2.6e/libbigloogc-2.6e.so $install_root/$install_prefix/lib/libbigloogc-2.6e.so

popd > /dev/null

