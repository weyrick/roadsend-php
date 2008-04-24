######################
#
# common makefile included by all extension makefiles
#
PCC_ROOT = ../../..
include $(PCC_ROOT)/bigloo-rules.mk

# generate dependency list from SOURCE_LIST
# this includes source files and safe/unsafe object files
SOURCE_FILES     := $(patsubst %,%.php,$(SOURCE_LIST))
POPULATION       := $(patsubst %,%_$(SU).o,$(SOURCE_LIST))

# phpoo root directory (relative to path of extension directory)
TOPLEVEL        = ../../../

# location bigloo libs will be built to and included from
LIB		= $(TOPLEVEL)libs

# from top level
DOTEST		= ./dotest
MY_TESTDIR	= $(MY_DIR)tests/
MY_TESTOUTDIR	= $(MY_TESTDIR)testoutput/

PCC_COMMON	= -v -L $(PCC_ROOT)/libs -L $(BIGLOO_LIB_PATH)

TAGFILE		= $(LIBNAME).tags
APIDOCFILE	= $(TOPLEVEL)doc/api/ext-$(LIBNAME).texi

#

all: unsafe

all-run: build-lib $(LIB)/lib$(LIBNAME)_$(SUV).a $(LIB)/$(LIBNAME).sch  $(LIB)/lib$(LIBNAME)_$(SUV).$(SOEXT) $(LIB)/$(LIBNAME).heap

unsafe:
	UNSAFE=t $(MAKE) all-run

safe: 
	UNSAFE=f $(MAKE) all-run

debug: safe

build-lib: lib$(LIBNAME)_$(SUV).$(SOEXT)

lib$(LIBNAME)_$(SUV).$(SOEXT): $(SOURCE_FILES) $(LIB_INIT_FILE)
	LD_LIBRARY_PATH="$(LD_LIBRARY_PATH):$(PCC_ROOT)/libs:$(BIGLOO_LIB_PATH)" PCC_CONF="" \
        $(PCC_ROOT)/compiler/pcc $(PCC_COMMON) -l $(LIBNAME) --lib-init-file $(LIB_INIT_FILE) $(SOURCE_FILES)

tags: $(TAGFILE)

$(TAGFILE): $(SOURCE_FILES)
	$(TOPLEVEL)/compiler/pcctags $(LIBNAME) $(SOURCE_FILES) > $(TAGFILE)

$(LIB)/lib$(LIBNAME)_$(SUV).$(SOEXT): lib$(LIBNAME)_$(SUV).$(SOEXT)
	cp lib$(LIBNAME)_$(SUV).$(SOEXT) $(LIB)/

$(LIB)/lib$(LIBNAME)_$(SUV).a: lib$(LIBNAME)_$(SUV).a
	cp lib$(LIBNAME)_$(SUV).a $(LIB)/

$(LIB)/$(LIBNAME).heap: $(LIBNAME).heap
	cp $(LIBNAME).heap $(LIB)/

$(LIB)/$(LIBNAME).sch: $(LIBNAME).sch
	cp $(LIBNAME).sch $(LIB)/

clean:
	-/bin/rm -f *.o *.a *.heap *~ *.so *.sch
	-/bin/rm $(TAGFILE)
	-/bin/rm -rf $(TOPLEVEL)$(MY_TESTOUTDIR)
	-/bin/rm $(LIB)/lib$(LIBNAME)_$(SUV).$(SOEXT) $(LIB)/lib$(LIBNAME)_$(SUV).a $(LIB)/$(LIBNAME).heap $(LIB)/$(LIBNAME).sch

check: all
	mkdir -p $(TOPLEVEL)$(MY_TESTOUTDIR)
	@(cd $(TOPLEVEL) && PCC_OPTS="-u $(LIBNAME) $(OTHER_PCC_LIBS)" $(DOTEST) $(MY_TESTDIR) $(MY_TESTOUTDIR))

