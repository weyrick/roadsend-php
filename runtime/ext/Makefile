#
# build,clean,check all extensions
#

PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

WIN_EXT_LIST	= pcc-win

all: unsafe

unsafe:
	UNSAFE=t $(MAKE) all-run

safe:
	UNSAFE=f $(MAKE) all-run

debug: safe

all-run:
	@for d in $(EXT_LIST); do \
           if [ -d $$d ]; then \
	     export UNSAFE; \
             echo "making extension $$d ..."; \
             (cd $$d && $(MAKE) all-run); \
           fi \
        done
ifeq ($(PCC_OS),PCC_MINGW)
	@for d in $(WIN_EXT_LIST); do \
           if [ -d $$d ]; then \
             export UNSAFE; \
             echo "making windows only extension $$d ..."; \
             (cd $$d && $(MAKE) all-run); \
           fi \
        done
endif

tags:
	@for d in $(EXT_LIST); do \
           if [ -d $$d ]; then \
             echo "tagging extension $$d ..."; \
             (cd $$d && $(MAKE) tags); \
           fi \
        done
ifeq ($(PCC_OS),PCC_MINGW)
	@for d in $(WIN_EXT_LIST); do \
           if [ -d $$d ]; then \
             echo "tagging windows only extension $$d ..."; \
             (cd $$d && $(MAKE) tags); \
           fi \
        done
endif

apidocs:
	@for d in $(EXT_LIST); do \
           if [ -d $$d ]; then \
             echo "apidoc'ing extension $$d ..."; \
             (cd $$d && $(MAKE) apidocs); \
           fi \
        done
	@for d in $(WIN_EXT_LIST); do \
           if [ -d $$d ]; then \
             echo "apidoc'ing windows only extension $$d ..."; \
             (cd $$d && $(MAKE) apidocs); \
           fi \
        done

clean:
	@for d in $(EXT_LIST); do \
           if [ -d $$d ]; then \
             echo "cleaning extension $$d ..."; \
             (cd $$d && $(MAKE) clean); \
           fi \
        done
ifeq ($(PCC_OS),PCC_MINGW)
	@for d in $(WIN_EXT_LIST); do \
           if [ -d $$d ]; then \
             echo "cleaning windows only extension $$d ..."; \
             (cd $$d && $(MAKE) clean); \
           fi \
        done
endif

check:
	@for d in $(EXT_LIST); do \
           if [ -d $$d ]; then \
             echo "checking extension $$d ..."; \
             (cd $$d && $(MAKE) check); \
           fi \
        done
