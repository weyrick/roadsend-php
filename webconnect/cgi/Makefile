PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

OS 		= $(shell uname -s)

BIGLOO_VERSION  = `bigloo -eval '(begin (print *bigloo-version*) (exit 0))'`     
PHPOO_INC	= -I ../.. -library profiler
BCOMMONFLAGS	= -L ../../libs -copt -I/usr/local/include 

SOURCE_LIST	= cgi make-lib

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))

# cgen binary
CGEN		= $(shell which cgen)


all: cgi-libs


cgi-libs: ../../libs/libcgi_$(SUV).$(SOEXT) ../../libs/libcgi_$(SUV).a

../../libs/libcgi_$(SUV).$(SOEXT): ../../libs/cgi.heap $(POPULATION) 
	$(call dllcmd,../../libs/libcgi_$(SUV).$(SOEXT)) $(POPULATION) $(CGI_DLL_LIBS)

../../libs/libcgi_$(SUV).a: ../../libs/cgi.heap $(STATIC_POPULATION)
	ar ruv ../../libs/libcgi_$(SUV).a $(STATIC_POPULATION)

../../libs/cgi.heap: $(POPULATION)
	$(BIGLOO) $(BHEAPFLAGS) make-lib.scm -heap-library cgi -addheap ../../libs/cgi.heap

#####

clean:
	-rm -f *.a *.o *.heap *.so cgi*.c make-lib*.c $(CLEFTOVERS)




