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
LIBNAME		= php-odbc

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/odbc/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = php-odbc \
                  odbc-bindings

C_SOURCE_LIST   = odbc-utils

CFLAGS	= -copt $(ODBC_INCLUDE) -copt $(ODBC_LIBRARY_PATH)

OTHERLIBS       = $(ODBC_LIBRARY_PATH) $(ODBC_LIBRARY)

# include common extension makefile
include ../extensions.mk

php-odbc.o: odbc-utils_$(SU).o odbc-bindings_$(SU).o
