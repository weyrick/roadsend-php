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
LIBNAME		= php-xml

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/xml/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = xml \
		  c-bindings \
		  xml-additional-c-bindings

C_SOURCE_LIST	= scm-xml


CFLAGS	 	= -copt "$(XML_CFLAGS)"

C_SOURCE_FLAGS  = $(XML_CFLAGS)

EXT_LIBS 	= $(XML_LIBS)


OTHERLIBS       = $(EXT_LIBS)


# include common extension makefile
include ../extensions.mk

#c-bindings.scm: c-bindings.defs
#	$(CGEN) c-bindings.defs > c-bindings.scm
