PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

BCOMMONFLAGS	= -copt -D_ISOC99_SOURCE
CCOMMONFLAGS	=  -I. -I$(BGL_DEFAULT_LIB_DIR) -O -I/usr/local/include

SOURCE_LIST	= readline history
C_SOURCE_LIST   = 

C_SOURCE_FILES   := $(patsubst %,%.c,$(C_SOURCE_LIST))
C_POPULATION     := $(patsubst %,%_$(SU).o,$(C_SOURCE_LIST))
C_STATIC_POPULATION     := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(C_SOURCE_LIST))

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))

all: unsafe

all-run: readline-libs

unsafe:
	UNSAFE=t make all-run

safe:
	UNSAFE=f make all-run

debug: safe

readline-libs: ../../libs/libpcc-rl_$(SUV).$(SOEXT) ../../libs/libpcc-rl_$(SUV).a

../../libs/libpcc-rl_$(SUV).$(SOEXT): ../../libs/pcc-rl.heap $(POPULATION) $(C_POPULATION) 
	$(call dllcmd,../../libs/libpcc-rl_$(SUV).$(SOEXT)) $(POPULATION) $(C_POPULATION) $(READLINE_LIBS)

../../libs/libpcc-rl_$(SUV).a: ../../libs/pcc-rl.heap $(STATIC_POPULATION) $(C_STATIC_POPULATION)
	ar ruv ../../libs/libpcc-rl_$(SUV).a $(STATIC_POPULATION) $(C_STATIC_POPULATION)

../../libs/pcc-rl.heap: $(SOURCE_FILES)
	$(BIGLOO) $(BHEAPFLAGS) -heap-library pcc-rl make-lib.scm -addheap ../../libs/pcc-rl.heap

clean:
	-/bin/rm -f *.a *.o *.heap *.so $(CLEFTOVERS)

