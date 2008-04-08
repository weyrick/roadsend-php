PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

BCOMMONFLAGS	= -I $(PCC_ROOT)/libs -L $(PCC_ROOT)/libs
SOURCE_LIST	= c-interface
C_SOURCE_LIST   = c-glue

CCOMMONFLAGS	=  -I. -I$(BGL_DEFAULT_LIB_DIR) -O -I/usr/local/include -L$(PCC_ROOT)/libs -I$(PCC_ROOT)/runtime

C_SOURCE_FILES   := $(patsubst %,%.c,$(C_SOURCE_LIST))
C_POPULATION     := $(patsubst %,%_$(SU).o,$(C_SOURCE_LIST))
C_STATIC_POPULATION     := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(C_SOURCE_LIST))

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

#CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))

all: unsafe

all-run: c-interface-libs c-test

unsafe:
	UNSAFE=t $(MAKE) all-run

safe:
	UNSAFE=f $(MAKE) all-run

debug: safe


clean:
	-/bin/rm -f *.a *.o *.heap *.so $(CLEFTOVERS)
	-/bin/rm c-test c-interface_[su].c
	-/bin/rm $(PCC_ROOT)/libs/librephpc_$(SUV).a $(PCC_ROOT)/libs/librephpc_$(SUV).$(SOEXT) 

c-interface-libs: $(PCC_ROOT)/libs/librephpc_$(SUV).a $(PCC_ROOT)/libs/librephpc_$(SUV).$(SOEXT) 

$(PCC_ROOT)/libs/librephpc_$(SUV).$(SOEXT): $(POPULATION) $(C_POPULATION) 
	$(call dllcmd,$(PCC_ROOT)/libs/librephpc_$(SUV).$(SOEXT)) $(POPULATION) $(RUNTIME_DLL_LIBS) $(C_POPULATION)

$(PCC_ROOT)/libs/librephpc_$(SUV).a: $(STATIC_POPULATION) $(C_STATIC_POPULATION)
	ar ruv $(PCC_ROOT)/libs/librephpc_$(SUV).a $(STATIC_POPULATION) $(C_STATIC_POPULATION)

c-test: c-test.c
	$(CC) $(CCOMMONFLAGS) $(CSAFEFLAGS) $(C_PIC) c-test.c -o c-test -lrephpc_$(SUV) -lphp-runtime_$(SUV) -lphpeval_$(SUV) -lwebconnect_$(SUV) -lprofiler_$(SUV)

# override for -rm
%_s.o : %.scm
	$(BIGLOO) $(BSAFEFLAGS) -rm $(BIGLOO_PIC)  -c $< -o $@
