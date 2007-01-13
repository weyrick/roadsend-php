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
LIBNAME		= php-mysql

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/mysql/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = php-mysql \
                  c-bindings

CFLAGS	= -copt $(MYSQL_INCLUDE) -copt $(MYSQL_LIBRARY)

OTHERLIBS       = $(MYSQL_LIBRARY) -lmysqlclient

# include common extension makefile
include ../extensions.mk

php-mysql.o: c-bindings.o

#c-bindings.scm: c-bindings.defs
#	$(CGEN) c-bindings.defs > c-bindings.scm

