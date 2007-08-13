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
LIBNAME		= php-gtk

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/gtk/

# this should list all scheme files to be included in the library
# leave off .scm, however, since the list is used to generate other
# file names as well.
SOURCE_LIST     = php-gtk \
		  php-gdk \
		  gdk-enums \
		  gtk-enums \
		  gtk-style \
		  php-gtk-common \
		  custom-properties \
	 	  gtk-static \
		  php-gtkscintilla \
		  cigloo/gtk \
		  cigloo/gtkscintilla \
		  cigloo/signals \
		  cigloo/glade \
		  define-classes \
		  php-gtk-overrides \
		  php-gtk-signals \
		  php-glade

#		  gtk-foreign-types \


C_SOURCE_LIST   = 

EXT_LIBS	= #-library bgtk

#libraries that should be in the dependency list for the shared lib
#for this extension, so that dlopen() loads them
OTHERLIBS       = `gtk-config --libs` -L`bigloo -eval '(begin (print *default-lib-dir*) (exit 0))'` $(GLADE_LIBRARY) -lgtkscintilla -lglade

BCFLAGS		= -copt `gtk-config --cflags |sed  s/\ /\ \-copt\ /g` $(GLADE_INCLUDE)

# include common extension makefile
include ../extensions.mk

# dependencies
#gtk-foreign-types.scm: gtk-foreign-types.defs
#	$(CGEN) gtk-foreign-types.defs > gtk-foreign-types.scm
gdk-enums_$(SU).o: php-gtk-macros.sch

php-gtk-common_$(SU).o: php-gtk-macros.sch 

php-gdk_$(SU).o: php-gtk-macros.sch gdk-enums_$(SU).o php-gtk-common_$(SU).o

gtk-style_$(SU).o: php-gtk-common_$(SU).o

gtk-static_$(SU).o: php-gtk-common_$(SU).o

php-gtk_$(SU).o: php-gtk-macros.sch gtk-enums_$(SU).o php-gdk_$(SU).o gdk-enums_$(SU).o php-gtk-common_$(SU).o gtk-static_$(SU).o

custom-properties_$(SU).o: php-gtk-macros.sch

php-gtkscintilla_$(SU).o: cigloo/gtkscintilla_$(SU).o

