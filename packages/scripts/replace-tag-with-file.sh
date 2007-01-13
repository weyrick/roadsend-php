#!/bin/bash
#
# You can use this to replace an arbitrary string in a file with another file.
# Example:
#
#   replace-tag-with-file.sh "###LICENSE_HERE###" /my/dir/LICENSE /my/dir/rpm-spec-file-template
#
# This would replace the string "###LICENSE_HERE### with the contents of 
# /my/dir/LICENSE in the file /my/dir/rpm-spec-file-template, outputing the
# result to standard output.
#

if [ $# -ne 3 ] || [ ! -e $2 ] || [ ! -e $3 ]
then
  echo "Usage: $0 <tag> <replacement-filename> <file-to-replace-in>"
  exit 1
fi

tag=$1
replace_file=$2
file=$3

## check if a file ends with a newline
trailing-newline-p () {
  if [ -z "$(tail -1 $1 | cat -E | grep '\$')" ]
  then 
    return 1 # false - does not have trailing newline
  else 
    return 0 # true - does have trailing newline
  fi
}

## if the tag doesn't appear in the file, just cat the file
if ! grep "$tag" $file > /dev/null
then
  cat $file
  exit 0
fi

## number of lines in the file
lines=`wc -l $file | awk '{print $1}'`

## the beginning of the file up to but not including the tag
grep -B $lines "$tag" $file | grep -v "$tag"

## the replacement file
cat $replace_file

## if the replacement file does not end in a newline, output one
if ! trailing-newline-p $replace_file; 
then 
  echo "" 
fi

## the rest of the file, starting with the line after the tag
grep -A $lines "$tag" $file | grep -v "$tag"
