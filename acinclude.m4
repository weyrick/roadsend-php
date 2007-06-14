dnl Locate a program and check that its version is acceptable.
dnl AC_PROG_CHECK_VER(var, namelist, version-switch,
dnl 		      [version-extract-regexp], version-glob [, do-if-fail])
AC_DEFUN([AC_CHECK_PROG_VER],
[AC_CHECK_PROGS([$1], [$2])
if test -z "[$]$1"; then
  ac_verc_fail=yes
else
  # Found it, now check the version.
  AC_MSG_CHECKING([version of [$]$1])
changequote(<<,>>)dnl
  ac_prog_version=`<<$>>$1 $3 2>&1 ifelse(<<$4>>,,,
                   <<| sed -n 's/^.*patsubst(<<$4>>,/,\/).*$/\1/p'>>)`
  case $ac_prog_version in
    '') ac_prog_version_m="v. ?.??, bad"; ac_verc_fail=yes;;
    <<$5>>)
changequote([,])dnl
       ac_prog_version_m="$ac_prog_version, ok"; ac_verc_fail=no;;
    *) ac_prog_version_m="$ac_prog_version, bad"; ac_verc_fail=yes;;

  esac
  AC_MSG_RESULT([$ac_prog_version_m])
fi
ifelse([$6],,,
[if test $ac_verc_fail = yes; then
  $6
fi])
])


#Author
#
#    Akos Maroy <darkeye@tyrell.hu> 
#License
#
#    AllPermissive
#    Copying and distribution of this file, with or without modification, are permitted in any medium without royalty provided the copyright notice and this notice are preserved. Users of this software should generally follow the principles of the MIT License includings its disclaimer. 

AC_DEFUN([AC_CHECK_CURL], [
  succeeded=no

  if test -z "$CURL_CONFIG"; then
    AC_PATH_PROG(CURL_CONFIG, curl-config, no)
  fi

  if test "$CURL_CONFIG" = "no" ; then
    echo "*** The curl-config script could not be found. Make sure it is"
    echo "*** in your path, and that curl is properly installed."
    echo "*** Or see http://curl.haxx.se/"
  else
    dnl curl-config --version returns "libcurl &lt;version&gt;", thus cut the number
    CURL_VERSION=`$CURL_CONFIG --version | cut -d" " -f2`
    AC_MSG_CHECKING(for curl >= $1)
        VERSION_CHECK=`expr $CURL_VERSION \>\= $1`
        if test "$VERSION_CHECK" = "1" ; then
            AC_MSG_RESULT(yes)
            succeeded=yes

            AC_MSG_CHECKING(CURL_CFLAGS)
            CURL_CFLAGS=`$CURL_CONFIG --cflags`
            AC_MSG_RESULT($CURL_CFLAGS)

            AC_MSG_CHECKING(CURL_LIBS)
            CURL_LIBS=`$CURL_CONFIG --libs`
            AC_MSG_RESULT($CURL_LIBS)
        else
            CURL_CFLAGS=""
            CURL_LIBS=""
            ## If we have a custom action on failure, don't print errors, but
            ## do set a variable so people can do so.
            ifelse([$3], ,echo "can't find curl >= $1",)
        fi

        AC_SUBST(CURL_CFLAGS)
        AC_SUBST(CURL_LIBS)
  fi

  if test $succeeded = yes; then
     ifelse([$2], , :, [$2])
  else
     ifelse([$3], , AC_MSG_ERROR([Library requirements (curl) not met.]), [$3])
  fi
])

