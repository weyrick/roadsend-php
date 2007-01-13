######################
#
# common makefile included by all extension makefiles
#
PCC_ROOT = ../../..
include $(PCC_ROOT)/bigloo-rules.mk

# generate dependency list from SOURCE_LIST
# this includes source files and safe/unsafe object files
SOURCE_FILES     := $(patsubst %,%.scm,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))
STATIC_POPULATION       := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(SOURCE_LIST))

C_SOURCE_FILES   := $(patsubst %,%.c,$(C_SOURCE_LIST))
C_POPULATION     := $(patsubst %,%_$(SU).o,$(C_SOURCE_LIST))
C_STATIC_POPULATION     := $(patsubst %,%_$(SU)$(STATIC_SUFFIX).o,$(C_SOURCE_LIST))

CLEFTOVERS	 := $(patsubst %.o,%.c,$(POPULATION)) $(patsubst %.o,%.c,$(STATIC_POPULATION))

# cgen binary
CGEN		= $(shell which cgen)

# phpoo root directory (relative to path of extension directory)
TOPLEVEL        = ../../../

# location bigloo libs will be built to and included from
LIB		= $(TOPLEVEL)libs

PHPOO_INC	= -I ../.. -I $(TOPLEVEL) -I .. $(EXT_INCLUDE)
PHPOO_LIBS	= -L $(LIB) -library php-runtime  $(EXT_LIBS) #mingw -library profiler

# from top level
DOTEST		= ./dotest
MY_TESTDIR	= $(MY_DIR)tests/
MY_TEST5DIR	= $(MY_DIR)tests5/
MY_TESTOUTDIR	= $(MY_TESTDIR)testoutput/
MY_TEST5OUTDIR	= $(MY_TEST5DIR)testoutput/

CCOMMONFLAGS	= -I. -I$(BGL_DEFAULT_LIB_DIR) $(C_SOURCE_FLAGS)
BCOMMONFLAGS	=  $(CFLAGS) $(PHPOO_INC) $(PHPOO_LIBS)


TAGFILE		= $(LIBNAME).tags
APIDOCFILE	= $(TOPLEVEL)doc/api/ext-$(LIBNAME).texi

#

all: libs

# this is an interesting idea
# $(C_POPULATION) : %.o : %.c
# 	$(CC) $(CSAFEFLAGS) -c $< -o $@

# $(C_STATIC_POPULATION) : %_st.o : %.c
# 	$(CC) $(CSTATICFLAGS) -c $< -o $@


libs: $(LIB)/lib$(LIBNAME)_$(SUV).a $(LIB)/$(LIBNAME).sch  $(LIB)/lib$(LIBNAME)_$(SUV).$(SOEXT)
	-cp *.init $(LIB)

tags: $(TAGFILE)

$(TAGFILE): $(SOURCE_FILES)
	$(TOPLEVEL)/compiler/pcctags --scm-extension $(LIBNAME) $(SOURCE_FILES) > $(TAGFILE)

apidocs: $(APIDOCFILE)

$(APIDOCFILE): $(SOURCE_FILES)
	$(TOPLEVEL)/compiler/pcctags --apidoc --scm-extension $(LIBNAME) $(SOURCE_FILES) > $(APIDOCFILE)

#we call gcc -shared instead of ld -G because libs that use long long arithmetic
#(e.g. the mysql client lib) must be linked against libgcc.a (__cmpdi, yadda),
#and only gcc knows where that is.
#,--disable-auto-import
#  make-lib.o is included because it has the dynamic-load entry point
$(LIB)/lib$(LIBNAME)_$(SUV).$(SOEXT): $(LIB)/$(LIBNAME).heap $(POPULATION) $(C_POPULATION) make-lib.o
	$(call dllcmd,$(LIB)/lib$(LIBNAME)_$(SUV).$(SOEXT)) $(POPULATION) $(C_POPULATION) $(OTHERLIBS) make-lib.o $(EXTENSION_DLL_LIBS)

$(LIB)/lib$(LIBNAME)_$(SUV).a: $(LIB)/$(LIBNAME).heap $(STATIC_POPULATION) $(C_STATIC_POPULATION)
	ar ruv $(LIB)/lib$(LIBNAME)_$(SUV).a $(STATIC_POPULATION) $(C_STATIC_POPULATION)

$(LIB)/$(LIBNAME).heap: $(SOURCE_FILES) make-lib.scm
	$(BIGLOO) $(BHEAPFLAGS) make-lib.scm -heap-library $(LIBNAME) -addheap $(LIB)/$(LIBNAME).heap

$(LIB)/$(LIBNAME).sch: $(LIBNAME).sch
	cp $(LIBNAME).sch $(LIB)/$(LIBNAME).sch

make-lib.o: $(POPULATION)
	$(BIGLOO) -copt -fPIC -rm  $(CFLAGS) -mkaddlib -dload-sym -c make-lib.scm

clean:
	-/bin/rm -f *.o *.a *.heap *~ *.so $(CLEFTOVERS)
	-/bin/rm $(TAGFILE)
	-/bin/rm -rf $(TOPLEVEL)$(MY_TESTOUTDIR)

check: all
	-mkdir $(TOPLEVEL)$(MY_TESTOUTDIR)
	@(cd $(TOPLEVEL) && $(DOTEST) $(MY_TESTDIR) $(MY_TESTOUTDIR))

check5: all
	-mkdir $(TOPLEVEL)$(MY_TEST5OUTDIR)
	@(cd $(TOPLEVEL) && PHP=$(PHP5) PCC_OPTS=-5 $(DOTEST) $(MY_TEST5DIR) $(MY_TEST5OUTDIR))

