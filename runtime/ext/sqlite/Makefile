#
# Makefile for phpoo extension
#
# other required files: 
#  make-lib.scm - this should simply import all modules to be
#                 included in the library
#  (libname).init - used to supply bigloo with options to be added at
#                   compile time to code that uses this library
#
# directory structure:
#  test/        - make check will run all .php scripts in this directory
#                 with the dotest program. output will go into a directory
#                 'testoutput' which is created inside of test
#

# library name
LIBNAME		= php-sqlite

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/sqlite/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = php-sqlite \
                  sqlite3-bindings

C_SOURCE_LIST   = encode \
		  sqlite-utils

CFLAGS		= -copt "$(SQLITE_CFLAGS)"
C_SOURCE_FLAGS	= $(SQLITE_CFLAGS)

OTHERLIBS       = $(SQLITE_LIBS)

# include common extension makefile
include ../extensions.mk


