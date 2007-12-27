PCC_ROOT = ..
include $(PCC_ROOT)/bigloo-rules.mk

#-D_ISOC99_SOURCE is necessary for the isfinite and isnan macros
#-D_GNU_SOURCE includes _ISOC99_SOURCE and gives us some stuff for fstat
BCOMMONFLAGS	=  -copt -D_GNU_SOURCE # -D_ISOC99_SOURCE
CCOMMONFLAGS	=  -I. -I$(BGL_DEFAULT_LIB_DIR)

SLIB_FILES	= slib/format  slib/slib  slib/sort  slib/soundex  slib/strcase  slib/strsrch
SOURCE_LIST	= php-runtime php-hash php-object php-ini utils elongs opaque-math-binding \
                  grasstable url-rewriter signatures extended-streams constants finalizers \
                  php-errors builtin-interfaces resources blib $(SLIB_FILES)
C_SOURCE_LIST   = c-runtime opaque-math php-hash-helper pcc_snprintf

C_POPULATION     := $(patsubst %,%_$(SU).o,$(C_SOURCE_LIST))
C_STATIC_POPULATION     := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(C_SOURCE_LIST))

SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))


all: runtime-libs extensions

tags: 
	cd ext && $(MAKE) tags

runtime-libs: ../libs/libphp-runtime_$(SUV).a ../libs/php-runtime.sch ../libs/libphp-runtime_$(SUV).$(SOEXT) 

extensions:
	@(cd ext && $(MAKE) all)

php-extensions:
	@(cd php-ext && $(MAKE) all)

#
../libs/libphp-runtime_$(SUV).$(SOEXT): ../libs/php-runtime.heap $(POPULATION) $(C_POPULATION) 
	$(call dllcmd,../libs/libphp-runtime_$(SUV).$(SOEXT)) $(POPULATION) $(C_POPULATION) $(RUNTIME_DLL_LIBS)

../libs/libphp-runtime_$(SUV).a: ../libs/php-runtime.heap $(STATIC_POPULATION) $(C_STATIC_POPULATION)
	ar ruv ../libs/libphp-runtime_$(SUV).a $(STATIC_POPULATION) $(C_STATIC_POPULATION)

../libs/php-runtime.heap: php-runtime.sch $(SOURCE_FILES)
	$(BIGLOO) $(BHEAPFLAGS) -heap-library php-runtime make-lib.scm -addheap ../libs/php-runtime.heap

../libs/php-runtime.sch: php-runtime.sch
	cp php-runtime.sch ../libs/php-runtime.sch

clean:
	-/bin/rm -f *.a *.o *.heap *.so $(CLEFTOVERS) slib/*.o
	@(cd ext && $(MAKE) clean)
	@(cd php-ext && $(MAKE) clean)

utils_$(SU).o: grasstable_$(SU).o

php-hash_$(SU).o: utils_$(SU).o grasstable_$(SU).o php-hash-helper_$(SU).o opaque-math.h \
      php-runtime.sch 

php-ini_$(SU).o: php-hash_$(SU).o utils_$(SU).o

opaque-math-binding_$(SU).o: opaque-math_$(SU).o

opaque-math_$(SU).o: opaque-math.h opaque-piddle.h

php-runtime_$(SU).o: ../php-macros.scm elongs_$(SU).o slib/slib_$(SU).o opaque-math-binding_$(SU).o \
      php-object_$(SU).o php-hash_$(SU).o utils_$(SU).o php-runtime.sch url-rewriter_$(SU).o signatures_$(SU).o \
      constants_$(SU).o php-ini_$(SU).o extended-streams_$(SU).o finalizers_$(SU).o resources_$(SU).o

slib/slib_$(SU).o: slib/format_$(SU).o  slib/sort_$(SU).o  slib/soundex_$(SU).o  slib/strcase_$(SU).o  slib/strsrch_$(SU).o

#make-lib_$(SU).o: utils_$(SU).o elongs_$(SU).o php-object_$(SU).o           \
#      php-hash_$(SU).o php-runtime_$(SU).o php-runtime.sch 

php-object_$(SU).o: utils_$(SU).o php-hash_$(SU).o grasstable_$(SU).o    \
      php-runtime.sch 

php-errors_$(SU).o: php-object_$(SU).o

builtin-interfaces_$(SU).o: php-object_$(SU).o

signatures.o: opaque-math-binding.o
