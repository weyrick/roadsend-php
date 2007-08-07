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


# Mateusz Loskot <mateusz@loskot.net>
with_sqlite3=no
AC_DEFUN([AX_LIB_SQLITE3],
[
    AC_ARG_WITH([sqlite3],
        AC_HELP_STRING(
            [--with-sqlite3=@<:@ARG@:>@],
            [use SQLite 3 library @<:@default=yes@:>@, optionally specify the prefix for sqlite3 library]
        ),
        [
        if test "$withval" = "no"; then
            WANT_SQLITE3="no"
        elif test "$withval" = "yes"; then
            WANT_SQLITE3="yes"
            ac_sqlite3_path=""
        else
            WANT_SQLITE3="yes"
            ac_sqlite3_path="$withval"
        fi
        ],
        [WANT_SQLITE3="yes"]
    )

    SQLITE3_CFLAGS=""
    SQLITE3_LDFLAGS=""
    SQLITE3_VERSION=""

    if test "x$WANT_SQLITE3" = "xyes"; then

        ac_sqlite3_header="sqlite3.h"

        sqlite3_version_req=ifelse([$1], [], [3.0.0], [$1])
        sqlite3_version_req_shorten=`expr $sqlite3_version_req : '\([[0-9]]*\.[[0-9]]*\)'`
        sqlite3_version_req_major=`expr $sqlite3_version_req : '\([[0-9]]*\)'`
        sqlite3_version_req_minor=`expr $sqlite3_version_req : '[[0-9]]*\.\([[0-9]]*\)'`
        sqlite3_version_req_micro=`expr $sqlite3_version_req : '[[0-9]]*\.[[0-9]]*\.\([[0-9]]*\)'`
        if test "x$sqlite3_version_req_micro" = "x" ; then
            sqlite3_version_req_micro="0"
        fi

        sqlite3_version_req_number=`expr $sqlite3_version_req_major \* 1000000 \
                                   \+ $sqlite3_version_req_minor \* 1000 \
                                   \+ $sqlite3_version_req_micro`

        AC_MSG_CHECKING([for SQLite3 library >= $sqlite3_version_req])

        if test "$ac_sqlite3_path" != ""; then
            ac_sqlite3_ldflags="-L$ac_sqlite3_path/lib"
            ac_sqlite3_cppflags="-I$ac_sqlite3_path/include"
        else
            for ac_sqlite3_path_tmp in /usr /usr/local /opt ; do
                if test -f "$ac_sqlite3_path_tmp/include/$ac_sqlite3_header" \
                    && test -r "$ac_sqlite3_path_tmp/include/$ac_sqlite3_header"; then
                    ac_sqlite3_path=$ac_sqlite3_path_tmp
                    ac_sqlite3_ldflags="-I$ac_sqlite3_path_tmp/include"
                    ac_sqlite3_cppflags="-L$ac_sqlite3_path_tmp/lib"
                    break;
                fi
            done
        fi

        ac_sqlite3_ldflags="$ac_sqlite3_ldflags -lsqlite3"

        saved_CPPFLAGS="$CPPFLAGS"
        CPPFLAGS="$CPPFLAGS $ac_sqlite3_cppflags"

        AC_LANG_PUSH(C++)
        AC_COMPILE_IFELSE(
            [
            AC_LANG_PROGRAM([[@%:@include <sqlite3.h>]],
                [[
#if (SQLITE_VERSION_NUMBER >= $sqlite3_version_req_number)
// Everything is okay
#else
#  error SQLite version is too old
#endif
                ]]
            )
            ],
            [
            AC_MSG_RESULT([yes])
            success="yes"
            ],
            [
            AC_MSG_RESULT([not found])
            succees="no"
            ]
        )
        AC_LANG_POP([C++])

        CPPFLAGS="$saved_CPPFLAGS"

        if test "$success" = "yes"; then

	    with_sqlite3=yes
            SQLITE3_CFLAGS="$ac_sqlite3_cppflags"
            SQLITE3_LDFLAGS="$ac_sqlite3_ldflags"

            ac_sqlite3_header_path="$ac_sqlite3_path/include/$ac_sqlite3_header"

            dnl Retrieve SQLite release version
            if test "x$ac_sqlite3_header_path" != "x"; then
                ac_sqlite3_version=`cat $ac_sqlite3_header_path \
                    | grep '#define.*SQLITE_VERSION.*\"' | sed -e 's/.* "//' \
                        | sed -e 's/"//'`
                if test $ac_sqlite3_version != ""; then
                    SQLITE3_VERSION=$ac_sqlite3_version
                else
                    AC_MSG_WARN([Can not find SQLITE_VERSION macro in sqlite3.h header to retrieve SQLite version!])
                fi
            fi

            AC_SUBST(SQLITE3_CFLAGS)
            AC_SUBST(SQLITE3_LDFLAGS)
            AC_SUBST(SQLITE3_VERSION)
            AC_DEFINE(HAVE_SQLITE3)
        fi
    fi
])


AC_DEFUN([AC_DEFINE_DIR], [
  prefix_NONE=
  exec_prefix_NONE=
  test "x$prefix" = xNONE && prefix_NONE=yes && prefix=$ac_default_prefix
  test "x$exec_prefix" = xNONE && exec_prefix_NONE=yes && exec_prefix=$prefix
dnl In Autoconf 2.60, ${datadir} refers to ${datarootdir}, which in turn
dnl refers to ${prefix}.  Thus we have to use `eval' twice.
  eval ac_define_dir="\"[$]$2\""
  eval ac_define_dir="\"$ac_define_dir\""
  AC_SUBST($1, "$ac_define_dir")
  AC_DEFINE_UNQUOTED($1, "$ac_define_dir", [$3])
  test "$prefix_NONE" && prefix=NONE
  test "$exec_prefix_NONE" && exec_prefix=NONE
])

