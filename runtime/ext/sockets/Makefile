#
# Skeleton Makefile for PCC extension
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
LIBNAME		= php-sockets

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/sockets/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = 

# C source files 
C_SOURCE_LIST   = 

# additional C libraries needed during link
EXT_LIBS	= 

# libraries that should be in the dependency list for the shared lib
# for this extension, so that dlopen() loads them
OTHERLIBS       = 

# these flags are C flags passed to bigloo, and should be in the form "-copt CFLAGS"
# bigloo will pass them on to the C compiler
BCFLAGS =

# these flags are passed directly to the C compiler
C_SOURCE_FLAGS  = 

# include common extension makefile
include ../extensions.mk

# dependencies
