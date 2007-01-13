#!/bin/bash

if [ $# -ne 3 ] || [ ! -e $1 ]
then
  echo "Usage: $0 <filelist> <source_dir> <install_prefix>"
  echo ""
  echo "<filelist> should be the name of a file containing the list of files to be found"
  echo "<source_dir> is the directory to search for the files in"
  echo "<install_prefix> is the prefix that the files were installed under, usually /usr or /usr/local"
  exit 1
fi

filelist=`grep -E -v "^\#" $1` # ignore commented lines
source_dir=$2
source_files=`find $source_dir -type f`
install_prefix=$3

same-file-p () {
  diff -q $1 $2 > /dev/null
  return $?
}

string-replace () {
  to_be_replaced=$1
  replacement=$2
  string=$3
  sep=$4
  if [ -z "$sep" ]; then
    sep='%'
  fi
  sed_expr="sed s`echo $sep``echo $to_be_replaced``echo $sep``echo $replacement``echo $sep`"
  echo $string | `echo $sed_expr`
}

cat <<EOF
#!/bin/bash

# This install script was automatically generated. You still have to add -s switches to
# the install statements to strip binaries and shared libraries, and you have to change
# the link targets to be relative rather than absolute paths so that they will survive
# relocation intact. You may also want to add links in /usr/lib for libraries, etc.
# Any files that could not be found in the source directory will be printed with a
# comment. You will have to figure out where these come from or how they are generated
# and add the code for that yourself. Going into the source directory and doing a
# "make -n install | grep filename" should be helpful.

if [ \$# -ne 2 ]
then
    echo "Usage: \$0 <source-root> <install-root>"
    exit 1
fi

source_root=\$1
install_root=\$2

EOF

for file in $filelist
do
  if [ ! -e $file ]
  then
    echo "# NOT INSTALLED: $file"
    continue
  fi
  found="no"
  if [ -L $file ]
  then
    found="yes"
    link_target=`string-replace $install_prefix '$install_root' $(realpath $file) '%'`
    link_name=`string-replace $install_prefix '$install_root' $file '%'`
    echo "ln -s $link_target $link_name"
  else
    for source_file in $source_files
    do
      if same-file-p $file $source_file
      then
        found="yes"
        mode=`stat --format='%a' $file`
        install_orig=`string-replace $source_dir '$source_root' $source_file '%'`
        install_dest=`string-replace $install_prefix '$install_root' $file '%'`
        echo "install --mode=$mode -D $install_orig $install_dest"
        break
      fi
    done
  fi
  if [ "$found" == "no" ]
  then
    echo "# NOT FOUND: $file"
  fi
done
