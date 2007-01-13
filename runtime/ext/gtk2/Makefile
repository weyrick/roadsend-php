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
LIBNAME		= php-gtk2

# library location
# (relative to phpoo root directory)
MY_DIR		= ./runtime/ext/gtk2/

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
		  cigloo/gtk \
		  cigloo/signals \
		  cigloo/glade \
		  define-classes \
		  php-gtk-overrides \
		  php-gtk-signals \
		  php-glade

#		  cigloo/gtkscintilla \
#		  php-gtkscintilla \


C_SOURCE_LIST   = 

EXT_LIBS	= #-library bgtk

#libraries that should be in the dependency list for the shared lib
#for this extension, so that dlopen() loads them
OTHERLIBS       = `pkg-config --libs gtk+-2.0 libglade-2.0` -L`bigloo -eval '(begin (print *default-lib-dir*) (exit 0))'` #-lgtkscintilla

CFLAGS		= -copt `pkg-config --cflags gtk+-2.0 libglade-2.0 |sed  -r s/[[:blank:]]\+-/\ \-copt\ -/g` #$(GLADE_INCLUDE)

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

gtk-enmum_$(SU).o: php-gtk-macros.sch

custom-properties_$(SU).o: php-gtk-macros.sch

#php-gtkscintilla_$(SU).o: cigloo/gtkscintilla_$(SU).o

check: all
	-rm -rf testoutput
	-mkdir testoutput
	PHP=$(PHP5) PCC_OPTS="-5 -u php-gtk2" ../../../dotest tests/ testoutput/
