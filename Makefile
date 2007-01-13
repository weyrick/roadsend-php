#
# Roadsend PHP Compiler
#
# First, make sure you have a Makefile.config in place. This should be a symlink to
# one of the Makefile.<platform> files.
#
# important targets:
#
# all        	- build support libraries, runtime, extensions, web backends and compiler
# unsafe     	- same as "all", but build "unsafe" (production) version
#              	  the production version is called "unsafe" for historical bigloo
#              	  reasons
# runtime    	- build the runtime libraries (including extensions)
# web-backends	  build web backends (microserver, fastcgi)
# tags       	- generate tags files for extensions
# clean      	- clean entire devel tree
# dotest     	- build "dotest" regression testing program
# check      	- run main test suite, using dotest program
# check5     	- run PHP5 specific test suite
# check-all  	- run main test suite, and all extension test suites
#

PCC_ROOT = .
include bigloo-rules.mk

PWD 	= `pwd`
VERBOSE =
BIGLOO 	= bigloo 

# paths needed for the install script
INSTALL_ROOT	= /
INSTALL_PREFIX	= /usr/

all: libs libs/libwebserver.$(SOEXT) profiler runtime webconnect \
     compiler extensions web-backends debugger shortpath dotest 

unsafe: 
	UNSAFE=t $(MAKE) all

tags: unsafe
	cd runtime && $(MAKE) tags

libs/libwebserver.$(SOEXT):
	(cd tools/libwebserver && \
         ./configure --libdir=$(PCC_HOME)/libs --includedir=$(PCC_HOME)/libs && \
         $(MAKE) all && \
         $(MAKE) install)

shortpath:
	(cd tools/shortpath && $(MAKE) shortpath)

#runtime
runtime: 
	(cd runtime && $(MAKE) runtime-libs)
.PHONY: runtime

#extensions
extensions: 
	(cd runtime && $(MAKE) extensions)

#compiler
compiler: webconnect
	(cd compiler && $(MAKE) all)
.PHONY: compiler

#debugger
debugger: web-backends
	(cd compiler && $(MAKE) debugger)
.PHONY: debugger

#webconnect
webconnect: 
	(cd webconnect && $(MAKE) all)
.PHONY: webconnect

#web backends
web-backends: webconnect compiler runtime
	(cd webconnect && $(MAKE) web-backends)

#profiler
profiler: libs
	(cd tools/profiler && $(MAKE) all)


.PHONY: libs
libs: 
	-mkdir libs
#	-mkdir libs/dlls

clean: 
	-rm -rf testoutput
	-rm -f *.c *.o *.so libs/*.so libs/*.heap libs/*.a libs/*.dll libs/*.init libs/*.sch
	(cd runtime && $(MAKE) clean && UNSAFE=t $(MAKE) clean)
	(cd compiler && $(MAKE) clean && UNSAFE=t $(MAKE) clean)
	(cd webconnect && $(MAKE) clean && UNSAFE=t $(MAKE) clean)
	(cd bugs && $(MAKE) clean && UNSAFE=t $(MAKE) clean)
#	(cd doc && $(MAKE) clean && UNSAFE=t $(MAKE) clean)
	(cd tools/profiler && $(MAKE) clean && UNSAFE=t $(MAKE) clean)
	-(cd tools/libwebserver && $(MAKE) clean)

dotest: dotest.scm 
	$(BIGLOO) -srfi $(PCC_OS) -copt -D$(PCC_OS) dotest.scm -o dotest $(DOTEST_LIBS)

check: dotest #all
	-rm -rf testoutput
	-mkdir testoutput
	./dotest tests/ testoutput/

check5: dotest
	-rm -rf testoutput
	-mkdir testoutput
	PHP=$(PHP5) PCC_OPTS=-5 ./dotest tests5/ testoutput/

check-all: all check
	(cd runtime/ext && $(MAKE) check)

docs:
	(cd doc && $(MAKE))

install: unsafe
	./install.sh $(INSTALL_ROOT) $(INSTALL_PREFIX)

install-runtime: unsafe
	./install-runtime.sh $(INSTALL_ROOT) $(INSTALL_PREFIX)

.PHONY: etags
etags: 
	etags `(cd _darcs/current; find . -regex '.*\.\(sc[mh]\|[ch]\)')`
