#!/bin/bash

if [ $# -ne 3 ]
then
    echo "Usage: $0 <source-root> <install-root> <install-prefix>"
    exit 1
fi

source_root=$1
install_root=$2
install_prefix=$3

pushd $source_root > /dev/null

./configure --prefix=$install_prefix --jvm=no && make

popd > /dev/null

install --mode=755 -D -s $source_root/bin/bigloo $install_root/$install_prefix/bin/bigloo
install --mode=755 -D $source_root/runtime/Include/bigloo.h $install_root/$install_prefix/lib/bigloo/2.6d/bigloo.h
install --mode=755 -D $source_root/lib/2.6d/bigloo.h $install_root/$install_prefix/lib/bigloo/2.6d/bigloo.h
install --mode=755 -D $source_root/lib/2.6d/bigloo_config.h $install_root/$install_prefix/lib/bigloo/2.6d/bigloo_config.h
install --mode=755 -D $source_root/lib/2.6d/bigloo.heap $install_root/$install_prefix/lib/bigloo/2.6d/bigloo.heap
install --mode=755 -D $source_root/lib/2.6d/fthread.heap $install_root/$install_prefix/lib/bigloo/2.6d/fthread.heap
install --mode=755 -D -s $source_root/lib/2.6d/bmem/bmem.so $install_root/$install_prefix/lib/bigloo/2.6d/bmem/bmem.so
install --mode=755 -D -s $source_root/lib/2.6d/libbigloo_s-2.6d.so $install_root/$install_prefix/lib/bigloo/2.6d/libbigloo_s-2.6d.so
install --mode=755 -D -s $source_root/lib/2.6d/libbigloo_u-2.6d.so $install_root/$install_prefix/lib/bigloo/2.6d/libbigloo_u-2.6d.so
install --mode=755 -D -s $source_root/gc-boehm/libgc.so $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc-2.6d.so
install --mode=755 -D -s $source_root/lib/2.6d/libbigloogc-2.6d.so $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc-2.6d.so
install --mode=755 -D -s $source_root/lib/2.6d/libbigloogc_fth-2.6d.so $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc_fth-2.6d.so
install --mode=755 -D -s $source_root/gc-boehm_fth/libgc.so $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc_fth-2.6d.so
install --mode=755 -D -s $source_root/lib/2.6d/libbigloofth_s-2.6d.so $install_root/$install_prefix/lib/bigloo/2.6d/libbigloofth_s-2.6d.so
install --mode=755 -D $source_root/lib/2.6d/fthread.init $install_root/$install_prefix/lib/bigloo/2.6d/fthread.init

install --mode=755 -D $source_root/lib/2.6d/libbigloo_s-2.6d.a $install_root/$install_prefix/lib/bigloo/2.6d/libbigloo_s-2.6d.a
ranlib $install_root/$install_prefix/lib/bigloo/2.6d/libbigloo_s-2.6d.a

install --mode=755 -D $source_root/lib/2.6d/libbigloo_u-2.6d.a $install_root/$install_prefix/lib/bigloo/2.6d/libbigloo_u-2.6d.a
ranlib $install_root/$install_prefix/lib/bigloo/2.6d/libbigloo_u-2.6d.a

install --mode=755 -D $source_root/lib/2.6d/libbigloogc-2.6d.a $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc-2.6d.a
ranlib $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc-2.6d.a

install --mode=755 -D $source_root/lib/2.6d/libbigloogc_fth-2.6d.a $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc_fth-2.6d.a
ranlib $install_root/$install_prefix/lib/bigloo/2.6d/libbigloogc_fth-2.6d.a

install --mode=755 -D $source_root/lib/2.6d/libbigloofth_s-2.6d.a $install_root/$install_prefix/lib/bigloo/2.6d/libbigloofth_s-2.6d.a
ranlib $install_root/$install_prefix/lib/bigloo/2.6d/libbigloofth_s-2.6d.a

pushd $install_root/$install_prefix > /dev/null

ln -s bigloo/2.6d/libbigloofth_s-2.6d.so $install_root/$install_prefix/lib/libbigloofth_u-2.6d.so
ln -s bigloo/2.6d/libbigloo_s-2.6d.so $install_root/$install_prefix/lib/libbigloo_s-2.6d.so
ln -s bigloo/2.6d/libbigloo_u-2.6d.so $install_root/$install_prefix/lib/libbigloo_u-2.6d.so
ln -s bigloo/2.6d/libbigloogc-2.6d.so $install_root/$install_prefix/lib/libbigloogc-2.6d.so
ln -s bigloo/2.6d/libbigloogc_fth-2.6d.so $install_root/$install_prefix/lib/libbigloogc_fth-2.6d.so
ln -s bigloo/2.6d/libbigloofth_s-2.6d.so $install_root/$install_prefix/lib/libbigloofth_s-2.6d.so
ln -s bigloo/2.6d/libbigloofth_s-2.6d.so $install_root/$install_prefix/lib/libbigloofth_u-2.6d.so
ln -s bigloo/2.6d/libbigloofth_s-2.6d.a $install_root/$install_prefix/lib/libbigloofth_u-2.6d.a

popd > /dev/null

