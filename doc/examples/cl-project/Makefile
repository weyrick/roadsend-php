#
# This is a sample Makefile to demonstrate 
# how to call the Roadsend Compiler from 
# a Makefile in Unix to build various targets
#

SA_BINARY		= main
MHTTPD_BINARY		= main_httpd
LIBNAME			= libtest
MAINFILE 		= main.php
LIB_SOURCE_FILES	= main.php inc1.php inc2.php

DEBUG_LEVEL		= 2

# this may include optimization, static build, profiling, etc
#PCC_FLAGS		= -O --static
PCC_FLAGS		=

PCC_CMD		= pcc -d $(DEBUG_LEVEL) $(PCC_FLAGS)
PCC_LIB_CMD 	= $(PCC_CMD) -l $(LIBNAME) 
PCC_MHTTPD_CMD	= $(PCC_LIB_CMD) -s -o $(MHTTPD_BINARY)

all:
	@echo "select the target you want to create: standalone, library, mhttpd, cgi"

standalone: 
	$(PCC_CMD) -o $(SA_BINARY) $(MAINFILE)

library:
	$(PCC_LIB_CMD) $(LIB_SOURCE_FILES)

mhttpd: 
	$(PCC_MHTTPD_CMD) $(LIB_SOURCE_FILES)

cgi:
	echo "XXX not yet"

clean:
#	$(PCC_LIB_CMD) --clean $(LIB_SOURCE_FILES)
	-rm $(SA_BINARY)
	-rm $(MHTTPD_BINARY)
	-rm *.o *.so *.a *.heap *.sch

