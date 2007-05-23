#!/bin/sh
#
# run by the packaging system to create install scripts
# not meant to be run manually
#

if [ $# -ne 2 ]; then
  echo "Usage: $0 <install-root> <install-prefix>"
fi

# set this to "echo" for testing, otherwise leave it blank
debug=

install_root=$1
install_prefix=$2
pcc_home=$PCC_HOME
lib_dir=$install_root/$install_prefix/libs
module_root=$install_root/$install_prefix/modules
#apache1_dir=$module_root/apache1.3.x
#apache2_dir=$module_root/apache2.x
fcgi_dir=$module_root/fastcgi

echo "Installing runtime into $install_root with prefix $install_prefix."
echo "lib_dir    : $lib_dir" 
#echo "apache1_dir: $apache1_dir" 
#echo "apache2_dir: $apache2_dir" 
echo "fcgi_dir   : $fcgi_dir"

## the libraries, headers, heaps, and init files
echo "installing libraries"
$debug install -m 755 -d $lib_dir
$debug install -m 644 -s $pcc_home/libs/*_u*.so $lib_dir
$debug install -m 644 $pcc_home/libs/*_u*.a $lib_dir
$debug install -m 644 $pcc_home/libs/*.sch $lib_dir
$debug install -m 644 $pcc_home/libs/*.heap $lib_dir
$debug install -m 644 $pcc_home/libs/*.init $lib_dir

# other libs
echo "installing support libs (ie, libwebserver)"
$debug install -m 644 -s $pcc_home/support-libs/*.so $lib_dir
$debug install -m 644 $pcc_home/support-libs/*.a $lib_dir
$debug install -m 644 $pcc_home/support-libs/*.h $lib_dir

# web modules
echo "installing web modules"
$debug install -m 755 -d $module_root
$debug install -m 755 -d $fcgi_dir
#$debug install -m 755 -d $apache1_dir
#$debug install -m 755 -d $apache2_dir
$debug install -m 755 -s $pcc_home/webconnect/fastcgi/pcc.fcgi $fcgi_dir/pcc.fcgi
#[ -e $pcc_home/webconnect/apache1/mod_pcc.so ] && $debug install -m 644 $pcc_home/webconnect/apache1/mod_pcc.so $apache1_dir/mod_pcc.so
#[ -e $pcc_home/webconnect/apache2/mod_pcc2.so ] && $debug install -m 644 $pcc_home/webconnect/apache2/mod_pcc2.so $apache2_dir/mod_pcc2.so

echo "done"
