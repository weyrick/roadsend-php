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
LIBNAME		= pcc-win

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/pcc-win/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = windows
		  #c-bindings

C_SOURCE_LIST   = registry

#libraries that should be in the dependency list for the shared lib
#for this extension, so that dlopen() loads them
OTHERLIBS       = -mwindows


CFLAGS		= 
C_SOURCE_FLAGS	= 

# include common extension makefile
include ../extensions.mk

#c-bindings.scm: c-bindings.defs
#	$(CGEN) c-bindings.defs > c-bindings.scm

