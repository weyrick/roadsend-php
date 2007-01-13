PCC_ROOT = ..
include $(PCC_ROOT)/bigloo-rules.mk

OS 		= $(shell uname -s)

BIGLOO_VERSION  = `bigloo -eval '(begin (print *bigloo-version*) (exit 0))'`     
PHPOO_INC	= -I ../.. -library profiler
BCOMMONFLAGS	= -L ../libs -copt -I/usr/local/include 

SOURCE_LIST	= webconnect make-lib cgi

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))

# cgen binary
CGEN		= $(shell which cgen)

BE_LIST	= micro \
	  cgi \
	  fastcgi
#	  apache1 \
#	  apache2

all: webconnect-libs 

web-backends:
	@for d in $(BE_LIST); do \
           if [ -d $$d ]; then \
             echo "making web backend $$d ..."; \
             (cd $$d && $(MAKE) all); \
           fi \
        done	

# webconnect
webconnect-libs: ../libs/libwebconnect_$(SUV).$(SOEXT) ../libs/libwebconnect_$(SUV).a

../libs/libwebconnect_$(SUV).$(SOEXT): ../libs/webconnect.heap $(POPULATION) 
	$(call dllcmd,../libs/libwebconnect_$(SUV).$(SOEXT)) $(POPULATION) $(WEBCONNECT_DLL_LIBS)

../libs/libwebconnect_$(SUV).a: ../libs/webconnect.heap $(STATIC_POPULATION)
	ar ruv ../libs/libwebconnect_$(SUV).a $(STATIC_POPULATION)

../libs/webconnect.heap: $(POPULATION)
	$(BIGLOO) $(BHEAPFLAGS) make-lib.scm -heap-library webconnect -addheap ../libs/webconnect.heap

#####

clean:
	-rm -f *.a *.o *.heap *.so webconnect*.c make-lib*.c $(CLEFTOVERS)
	-rm -rf testoutput
	@for d in $(BE_LIST); do \
           if [ -d $$d ]; then \
             echo "cleaning backend $$d ..."; \
             (cd $$d && $(MAKE) clean); \
           fi \
        done



