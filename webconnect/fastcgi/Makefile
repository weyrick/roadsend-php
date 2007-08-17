PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

OS 		= $(shell uname -s)

BIGLOO_VERSION  = `bigloo -eval '(begin (print *bigloo-version*) (exit 0))'`     
PHPOO_INC	= -I ../.. -library profiler
BCOMMONFLAGS	= -L ../../libs -copt -I/usr/local/include -copt -I$(PCC_ROOT)/../include  -copt -L$(PCC_ROOT)/../lib

SOURCE_LIST	= fastcgi fcgi-binding

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))

all: pcc.fcgi

# This target is for use when developing -- it makes it easy for ld.so to find pcc.fcgi's libs
devel: $(POPULATION) fastcgi-main_$(SU).o
	bigloo $(SAFETY) $(PCC_LINK_OPTIONS) $(BCOMMONFLAGS) fastcgi-main_$(SU).o -ldopt -L/usr/local/lib -o pcc.fcgi \
		-library php-runtime -library profiler -library webconnect -library phpeval -library fastcgi -lfcgi \
	  	-ldopt -Wl,-rpath,$(PCC_HOME)/libs -ldopt -Wl,-rpath,$(BGL_DEFAULT_LIB_DIR)

pcc.fcgi: $(POPULATION) ../../libs/libfastcgi_$(SUV).$(SOEXT) ../../libs/libfastcgi_$(SUV).a fastcgi-main_$(SU).o
	bigloo $(SAFETY) $(PCC_LINK_OPTIONS) $(BCOMMONFLAGS) fastcgi-main_$(SU).o -ldopt -L/usr/local/lib -o pcc.fcgi \
		-library php-runtime -library profiler -library webconnect -library phpeval -library fastcgi -lfcgi 

# fastcgi libs
fastcgi-libs: ../../libs/libfastcgi_$(SUV).$(SOEXT) ../../libs/libfastcgi_$(SUV).a


../../libs/libfastcgi_$(SUV).$(SOEXT): ../../libs/fastcgi.heap $(POPULATION) make-lib.o
	$(call dllcmd,../../libs/libfastcgi_$(SUV).$(SOEXT)) $(POPULATION) make-lib.o -lfcgi $(FASTCGI_DLL_LIBS)

../../libs/libfastcgi_$(SUV).a: ../../libs/fastcgi.heap $(STATIC_POPULATION)
	ar ruv ../../libs/libfastcgi_$(SUV).a $(STATIC_POPULATION)

../../libs/fastcgi.heap: $(POPULATION)
	$(BIGLOO) $(BHEAPFLAGS) make-lib.scm -heap-library fastcgi -addheap ../../libs/fastcgi.heap

make-lib.o: $(POPULATION)
	$(BIGLOO) -copt -fPIC -rm  $(BCFLAGS) -mkaddlib -dload-sym -c make-lib.scm

fastcgi_$(SU).o: fcgi-binding_$(SU).o

#####

clean:
	-rm -f *.a *.o *.heap *.so pcc.fcgi fastcgi*.c make-lib*.c $(CLEFTOVERS)
