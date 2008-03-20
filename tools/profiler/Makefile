PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

BCOMMONFLAGS	= -copt -D_ISOC99_SOURCE
CCOMMONFLAGS	=  -I. -I$(BGL_DEFAULT_LIB_DIR) -O -I/usr/local/include

SOURCE_LIST	= profiler profiler-c-bindings
C_SOURCE_LIST   = $(WINDOWS_TIME_SUPPORT)


C_SOURCE_FILES   := $(patsubst %,%.c,$(C_SOURCE_LIST))
C_POPULATION     := $(patsubst %,%_$(SU).o,$(C_SOURCE_LIST))
C_STATIC_POPULATION     := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(C_SOURCE_LIST))

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))


all: unsafe

all-run: profiler-libs

unsafe:
	UNSAFE=t $(MAKE) all-run

safe:
	UNSAFE=f $(MAKE) all-run

debug: safe

profiler-libs: ../../libs/libprofiler_$(SUV).$(SOEXT) ../../libs/libprofiler_$(SUV).a

../../libs/libprofiler_$(SUV).$(SOEXT): ../../libs/profiler.heap $(POPULATION) $(C_POPULATION) 
	$(call dllcmd,../../libs/libprofiler_$(SUV).$(SOEXT)) $(POPULATION) $(C_POPULATION) $(PROFILER_DLL_LIBS) 

../../libs/libprofiler_$(SUV).a: ../../libs/profiler.heap $(STATIC_POPULATION) $(C_STATIC_POPULATION)
	ar ruv ../../libs/libprofiler_$(SUV).a $(STATIC_POPULATION) $(C_STATIC_POPULATION)

../../libs/profiler.heap: $(SOURCE_FILES)
	$(BIGLOO) $(BHEAPFLAGS) -heap-library profiler make-lib.scm -addheap ../../libs/profiler.heap

clean:
	-/bin/rm -f *.a *.o *.heap *.so $(CLEFTOVERS)

profiler_$(SU).o: profiler-c-bindings_$(SU).o

