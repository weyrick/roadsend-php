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
LIBNAME		= php-curl

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/curl/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = php-curl curl-c-bindings curl-bindings

C_SOURCE_LIST   = 

CFLAGS		= -copt "$(CURL_CFLAGS)"
STATICFLAGS	= -copt "$(CURL_STATIC_CFLAGS)"

OTHERLIBS       = $(CURL_LIBS)

# include common extension makefile
include ../extensions.mk

# dependencies
php-curl.o: curl-c-bindings.o

#curl.scm: curl.defs
#	$(CGEN) curl.defs > curl.scm
