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
bin_dir=$install_root/$install_prefix/bin
doc_dir=$install_root/$install_prefix/doc
man_dir=$install_root/$install_prefix/man
etc_dir=$install_root/etc

echo "Installing into $install_root with prefix $install_prefix."
echo "etc_dir    : $etc_dir"
echo "bin_dir    : $bin_dir" 
echo "doc_dir    : $doc_dir" 
echo "man_dir    : $man_dir" 

## the pcc man page (uncomment this when we have one)
#$debug install -m 755 -d $man_dir
#$debug install -m 644 $pcc_home/doc/pcc.1 $man_dir/pcc.1

## the license
$debug install -m 755 -d $doc_dir
$debug install -m 644 $pcc_home/packages/LICENSE $doc_dir/LICENSE

## the config file
$debug install -m 755 -d $etc_dir
$debug install -m 644 -b $pcc_home/doc/pcc.conf $etc_dir/pcc.conf

## the html documentation (manual & api)
$debug install -m 755 -d $doc_dir/manual/html
$debug install -m 644 $(find $pcc_home/doc/manual/html -name '*.html') $doc_dir/manual/html
$debug install -m 755 -d $doc_dir/api/html
$debug install -m 644 $(find $pcc_home/doc/api/html -name '*.html') $doc_dir/api/html
$debug install -m 755 -d $doc_dir/manual/html/resources
$debug install -m 644 $(find $pcc_home/doc/resources -name '*.png') $doc_dir/manual/html/resources

## the pcc binary
$debug install -m 755 -d $bin_dir
$debug install -m 755 -s $pcc_home/compiler/pcc $bin_dir/pcc
$debug install -m 755 -s $pcc_home/compiler/pcctags $bin_dir/pcctags

