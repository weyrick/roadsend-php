PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

OS 		= $(shell uname -s)

BIGLOO_VERSION  = `bigloo -eval '(begin (print *bigloo-version*) (exit 0))'`     
PHPOO_INC	= -I ../.. -library profiler
BCOMMONFLAGS	= -L ../../libs -copt -I/usr/local/include -copt -I$(PCC_ROOT)/../include  -copt -L$(PCC_ROOT)/../lib

SOURCE_LIST	= fastcgi fcgi-binding c-fcgi-bindings
C_SOURCE_LIST	= c-fcgi

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

C_SOURCE_FILES   := $(patsubst %,%.c,$(C_SOURCE_LIST))
C_POPULATION     := $(patsubst %,%_$(SU).o,$(C_SOURCE_LIST))
C_STATIC_POPULATION     := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(C_SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))

all: unsafe

all-run: clean-bin pcc.fcgi

unsafe: 
	UNSAFE=t make all-run

debug: safe

safe:
	UNSAFE=f make all-run

clean-bin:
	-rm pcc.fcgi

pcc.fcgi: pcc_$(SU).fcgi
	cp pcc_$(SU).fcgi pcc.fcgi

pcc_$(SU).fcgi: $(POPULATION) ../../libs/libfastcgi_$(SUV).$(SOEXT) ../../libs/libfastcgi_$(SUV).a fastcgi-main_$(SU).o
	bigloo $(SAFETY) $(PCC_LINK_OPTIONS) $(BCOMMONFLAGS) fastcgi-main_$(SU).o -ldopt -L/usr/local/lib -o pcc_$(SU).fcgi \
		-library php-runtime -library profiler -library webconnect -library phpeval -library fastcgi -lfcgi 

# fastcgi libs
fastcgi-libs: ../../libs/libfastcgi_$(SUV).$(SOEXT) ../../libs/libfastcgi_$(SUV).a


../../libs/libfastcgi_$(SUV).$(SOEXT): ../../libs/fastcgi.heap $(POPULATION) $(C_POPULATION) make-lib.o
	$(call dllcmd,../../libs/libfastcgi_$(SUV).$(SOEXT)) $(POPULATION) $(C_POPULATION) make-lib.o -lfcgi $(FASTCGI_DLL_LIBS)

../../libs/libfastcgi_$(SUV).a: ../../libs/fastcgi.heap $(STATIC_POPULATION) $(C_STATIC_POPULATION)
	ar ruv ../../libs/libfastcgi_$(SUV).a $(STATIC_POPULATION) $(C_STATIC_POPULATION)

../../libs/fastcgi.heap: $(POPULATION)
	$(BIGLOO) $(BHEAPFLAGS) make-lib.scm -heap-library fastcgi -addheap ../../libs/fastcgi.heap

make-lib.o: $(POPULATION)
	$(BIGLOO) -copt -fPIC -rm  $(BCFLAGS) -mkaddlib -dload-sym -c make-lib.scm

fastcgi_$(SU).o: fcgi-binding_$(SU).o

#####

clean:
	-rm -f *.a *.o *.heap *.so pcc.fcgi pcc_[us].fcgi fastcgi*.c make-lib*.c $(CLEFTOVERS)
