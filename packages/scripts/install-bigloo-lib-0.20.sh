#!/bin/bash

if [ $# -ne 4 ]
then
    echo "Usage: $0 <source-root> <install-root> <install-prefix> <bigloo-version>"
    exit 1
fi

source_root=$1
install_root=$2
install_prefix=$3
bigloo_version=$4

pushd $source_root > /dev/null

#./configure --prefix=$install_prefix && make

popd > /dev/null

install -d $install_root/$install_prefix/lib/bigloo/$bigloo_version
install -m 644  $source_root/common/md5.h $install_root/$install_prefix/lib/bigloo/$bigloo_version/md5.h
install -m 644  $source_root/common/common.sch $install_root/$install_prefix/lib/bigloo/$bigloo_version/common.sch
install -m 644  $source_root/common/common.h $install_root/$install_prefix/lib/bigloo/$bigloo_version/common.h
install -m 644  $source_root/common/common.heap $install_root/$install_prefix/lib/bigloo/$bigloo_version/common.heap
install -m 644  $source_root/common/common.init $install_root/$install_prefix/lib/bigloo/$bigloo_version/common.init
install -m 755  $source_root/common/.libs/libcommon_s.so.0 $install_root/$install_prefix/lib/bigloo/$bigloo_version/libcommon_s.so.0.0.0
install -m 755  $source_root/common/.libs/libcommon_s.a $install_root/$install_prefix/lib/bigloo/$bigloo_version/libcommon_s.a
install -m 755  $source_root/common/.libs/libcommon_s.lai $install_root/$install_prefix/lib/bigloo/$bigloo_version/libcommon_s.la

#gtk
# XXX removed for 1.6.0
#install -m 644  $source_root/bgtk/bgtk.sch $install_root/$install_prefix/lib/bigloo/$bigloo_version/bgtk.sch
#install -m 644  $source_root/bgtk/bgtk.h $install_root/$install_prefix/lib/bigloo/$bigloo_version/bgtk.h
#install -m 644  $source_root/bgtk/bgtk.heap $install_root/$install_prefix/lib/bigloo/$bigloo_version/bgtk.heap
#install -m 644  $source_root/bgtk/bgtk.init $install_root/$install_prefix/lib/bigloo/$bigloo_version/bgtk.init
#install -m 755  $source_root/bgtk/.libs/libbgtk_s.so.0 $install_root/$install_prefix/lib/bigloo/$bigloo_version/libbgtk_s.so.0.0.0
#install -m 755  $source_root/bgtk/.libs/libbgtk_s.a $install_root/$install_prefix/lib/bigloo/$bigloo_version/libbgtk_s.a
#install -m 755  $source_root/bgtk/.libs/libbgtk_s.lai $install_root/$install_prefix/lib/bigloo/$bigloo_version/libbgtk_s.la

pushd $install_root/$install_prefix/lib/bigloo/$bigloo_version > /dev/null

ln -s libcommon_u.a libcommon.a
ln -s libcommon_s.a libcommon_u.a
ln -s libcommon_s.la libcommon_u.la
ln -s libcommon_s.so.0.0.0 libcommon_s.so
ln -s libcommon_s.so.0.0.0 libcommon_s.so.0
ln -s libcommon_u.so.0.0.0 libcommon_u.so
ln -s libcommon_u.so.0.0.0 libcommon_u.so.0
ln -s libcommon_s.so.0.0.0 libcommon_u.so.0.0.0

#gtk
# removed for 1.6.0
#ln -s libbgtk_s.a libbgtk.a
#ln -s libbgtk_s.a libbgtk_u.a
#ln -s libbgtk_s.la libbgtk_u.la
#ln -s libbgtk_s.so.0.0.0 libbgtk_s.so
#ln -s libbgtk_s.so.0.0.0 libbgtk_s.so.0
#ln -s libbgtk_s.so.0.0.0 libbgtk_u.so
#ln -s libbgtk_s.so.0.0.0 libbgtk_u.so.0
#ln -s libbgtk_s.so.0.0.0 libbgtk_u.so.0.0.0

popd > /dev/null

pushd $install_root/$install_prefix/lib > /dev/null

ln -s bigloo/$bigloo_version/libcommon_s.so.0.0.0 libcommon_s.so
ln -s bigloo/$bigloo_version/libcommon_s.so.0.0.0 libcommon_s.so.0
ln -s bigloo/$bigloo_version/libcommon_s.so.0.0.0 libcommon_s.so.0.0.0
ln -s bigloo/$bigloo_version/libcommon_u.so.0.0.0 libcommon_u.so
ln -s bigloo/$bigloo_version/libcommon_u.so.0.0.0 libcommon_u.so.0
ln -s bigloo/$bigloo_version/libcommon_u.so.0.0.0 libcommon_u.so.0.0.0

#gtk
# removed for 1.6.0 
#ln -s bigloo/$bigloo_version/libbgtk_s.so.0.0.0 libbgtk_s.so
#ln -s bigloo/$bigloo_version/libbgtk_s.so.0.0.0 libbgtk_s.so.0
#ln -s bigloo/$bigloo_version/libbgtk_s.so.0.0.0 libbgtk_s.so.0.0.0
#ln -s bigloo/$bigloo_version/libbgtk_s.so.0.0.0 libbgtk_u.so
#ln -s bigloo/$bigloo_version/libbgtk_s.so.0.0.0 libbgtk_u.so.0
#ln -s bigloo/$bigloo_version/libbgtk_s.so.0.0.0 libbgtk_u.so.0.0.0

popd > /dev/null

