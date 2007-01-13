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
LIBNAME		= php-std

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/standard/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = php-strings \
                  php-math \
                  php-core \
                  php-files \
                  php-array \
                  php-variable \
                  php-eregexp \
                  php-output-control \
		  php-posix \
		  posix-c-bindings \
                  php-time \
		  time-c-bindings \
		  parsedate \
		  php-session \
		  php-streams \
		  php-network \
		  streams-c-bindings \
		  php-image


C_SOURCE_LIST   = strnatcmp \
		  crc \
		  mt_rand \
		  network \
		  c-files \
		  streams \
		  php-system \
		  pack \
		  $(WINDOWS_C_SUPPORT)

C_SOURCE_FLAGS = 

# include common extension makefile
include ../extensions.mk

#libraries that should be in the dependency list for the shared lib
#for this extension, so that dlopen() loads them
OTHERLIBS       = $(RESOLVER_LIBRARY) -L$(BGL_DEFAULT_LIB_DIR) -L/usr/local/lib

ifeq ($(PCC_OS), PCC_MINGW)
OTHERLIBS       := $(OTHERLIBS) -lgw32c -lole32 -luuid
endif

# dependencies
php-time_$(SU).o: parsedate_$(SU).o #windows-time_$(SU).o

php-session_$(SU).o: php-variable_$(SU).o php-math_$(SU).o php-time_$(SU).o #php-strings_$(SU).o #php-files_$(SU).o

php-files_$(SU).o: #php-strings_$(SU).o ../../../compiler/lexers.scm php-streams.sch streams-c-bindings_$(SU).o time-c-bindings_$(SU).o

php-core_$(SU).o: php-session_$(SU).o               \
#      php-output-control_$(SU).o php-eregexp_$(SU).o php-array_$(SU).o php-time_$(SU).o  \
#      php-math_$(SU).o php-strings_$(SU).o php-variable_$(SU).o         \
#      ../phpoo-extension.sch# ../../../compiler/driver.scm pack_$(SU).o #php-network_$(SU).o php-files_$(SU).o

php-array_$(SU).o: php-variable_$(SU).o php-math_$(SU).o #php-strings_$(SU).o

php-network_$(SU).o: streams-c-bindings_$(SU).o php-streams.sch php-streams_$(SU).o network_$(SU).o

php-streams_$(SU).o: streams-c-bindings_$(SU).o streams_$(SU).o php-streams.sch

php-strings_$(SU).o: php-math_$(SU).o

streams-c-bindings_$(SU).o: network.h streams.h
