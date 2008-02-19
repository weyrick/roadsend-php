#
# base make definitions that shouldn't change so much
# platform specific changes go into Makefile.<platform>
#

include $(PCC_ROOT)/Makefile.config
BIGLOO		= bigloo
BGL_DEFAULT_LIB_DIR = $(shell bigloo -eval '(begin (print *default-lib-dir*) (exit 0))')

#SU is for the _s or _u extensions
#SUV is for the _s or _u extensions + perhaps the version
#SAFETY is for when we use bigloo to link, like in compiler/Makefile
ifeq ($(UNSAFE),t)
	SU = u
	SUV = u-$(BIGLOOVERSION)
	SAFETY = -unsafe
else
	SU = s
	SUV = s-$(BIGLOOVERSION)
	SAFETY = 
endif

ifeq ($(PROFILE),t)
	PROFILEFLAGS = -pg
else
	PROFILEFLAGS =
endif

BHEAPFLAGS	= -unsafe -mkaddheap -mkaddlib

# -fsharing? 
# -mkaddlib shortens our startup time because it changes bigloo's constant allocation mode
BSAFEFLAGS	= -mkaddlib -unsafev -copt -D$(PCC_OS) -srfi $(PCC_OS) -O3 -g -cg +rm $(PROFILEFLAGS) $(BCOMMONFLAGS)
BUNSAFEFLAGS	= -mkaddlib -copt -D$(PCC_OS) -srfi $(PCC_OS) -srfi unsafe -O6 -unsafe $(BCOMMONFLAGS) 

# the -srfi bit makes cond-expand work in scheme code
CSAFEFLAGS    = -D$(PCC_OS) -O -g $(PROFILEFLAGS) $(CCOMMONFLAGS)
CUNSAFEFLAGS  = -D$(PCC_OS) -O4 $(CCOMMONFLAGS)

BIGLOO_LIBS	= -L$(BGL_DEFAULT_LIB_DIR) -lbigloo_$(SU)-$(BIGLOOVERSION) -lbigloogc-$(BIGLOOVERSION)

# we could put non-pic code in the static libraries without too much
# trouble by adding the t to STATIC_SUFFIX in linux, and not building
# the _st/_ut files with -fPIC, but I don't think that it makes a big
# enough performance difference to be worth it.

%_s.o : %.scm
	$(BIGLOO) $(BSAFEFLAGS) $(BIGLOO_PIC)  -c $< -o $@

%_st.o : %.scm
	$(BIGLOO) -static-bigloo $(STATICFLAGS) $(BSAFEFLAGS)  -c $< -o $@

%_u.o : %.scm
	$(BIGLOO) $(BUNSAFEFLAGS) $(BIGLOO_PIC)  -c $< -o $@

%_ut.o : %.scm
	$(BIGLOO) -static-bigloo $(STATICFLAGS) $(BUNSAFEFLAGS)  -c $< -o $@


# and for .c files
%_s.o : %.c
	$(CC) $(CSAFEFLAGS) $(C_PIC) -c $< -o $@

%_st.o : %.c
	$(CC) $(C_STATICFLAGS) -DSTATIC_BIGLOO $(CSAFEFLAGS) -c $< -o $@

%_u.o : %.c
	$(CC) $(CUNSAFEFLAGS) $(C_PIC) -c $< -o $@

%_ut.o : %.c
	$(CC) $(C_STATICFLAGS) -DSTATIC_BIGLOO $(CUNSAFEFLAGS) -c $< -o $@

%_u.o : %.cpp
	$(CXX) -c $< -o $@

%_ut.o : %.cpp
	$(CXX) $(CPP_STATICFLAGS) -DSTATIC_BIGLOO -c $< -o $@

