PCC_ROOT = ../../
include $(PCC_ROOT)/bigloo-rules.mk

BIGLOO_VERSION  = `bigloo -eval '(begin (print *bigloo-version*) (exit 0))'`     
BCOMMONFLAGS	= -L $(PCC_ROOT)libs -copt -I$(PCC_ROOT)libs -copt -I$(PCC_ROOT)/tools/libwebserver/include

# cgen binary
CGEN		= $(shell which cgen)

# mhttpd
M_SOURCE_LIST	= libws-c-bindings microhttpd make-mhttpd-lib
M_POPULATION	:= $(patsubst %,%_$(SU).o,$(M_SOURCE_LIST))
M_STATIC_POPULATION	:= $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(M_SOURCE_LIST))

all: unsafe

all-run: mhttpd-libs

unsafe:
	UNSAFE=t $(MAKE) all-run

safe: 
	UNSAFE=f $(MAKE) all-run

debug: safe

# mhttpd

mhttpd-libs: $(PCC_ROOT)libs/libmhttpd_$(SUV).$(SOEXT) $(PCC_ROOT)libs/libmhttpd_$(SUV).a

$(PCC_ROOT)libs/libmhttpd_$(SUV).$(SOEXT): $(PCC_ROOT)libs/mhttpd.heap $(M_POPULATION) 
	$(call dllcmd_i,$(PCC_ROOT)libs/libmhttpd_$(SUV).$(SOEXT)) $(M_POPULATION) $(MHTTPD_DLL_LIBS)

$(PCC_ROOT)libs/libmhttpd_$(SUV).a: $(PCC_ROOT)libs/mhttpd.heap $(M_STATIC_POPULATION)
	ar ruv $(PCC_ROOT)libs/libmhttpd_$(SUV).a $(M_STATIC_POPULATION)

$(PCC_ROOT)libs/mhttpd.heap: $(M_POPULATION)
	$(BIGLOO) $(BHEAPFLAGS) make-mhttpd-lib.scm -heap-library mhttpd -addheap $(PCC_ROOT)libs/mhttpd.heap

microhttpd_s.o: microhttpd.scm
	$(BIGLOO) $(BSAFEFLAGS) $(BIGLOO_PIC) $(LIBWS_INCLUDE) $(LIBWS_LIBRARY) -c $< -o $@

microhttpd_u.o: microhttpd.scm
	$(BIGLOO) $(BUNSAFEFLAGS) $(BIGLOO_PIC) $(LIBWS_INCLUDE) $(LIBWS_LIBRARY) -c $< -o $@

libws-c-bindings_s.o: libws-c-bindings.scm
	$(BIGLOO) $(BSAFEFLAGS) $(BIGLOO_PIC) $(LIBWS_INCLUDE) $(LIBWS_LIBRARY) -c $< -o $@

libws-c-bindings_u.o: libws-c-bindings.scm
	$(BIGLOO) $(BUNSAFEFLAGS) $(BIGLOO_PIC) $(LIBWS_INCLUDE) $(LIBWS_LIBRARY)  -c $< -o $@

#libws-c-bindings.scm: libws-c-bindings.defs
#	$(CGEN) libws-c-bindings.defs > libws-c-bindings.scm

clean:
	-rm -f *.a *.o *.heap *.so *bindings_[us].c make-mhttpd*.c mhttpd*.c microhttpd*.c $(CLEFTOVERS)
	-rm -rf testoutput


