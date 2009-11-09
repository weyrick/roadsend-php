#
# build,clean,check all extensions
#
#jfcouic 2008-11-05 : quotes PHP_EXT_LIST to have a good shell code, if to test if there is something to do before loop.

PCC_ROOT = ../..
include $(PCC_ROOT)/bigloo-rules.mk

all: unsafe

unsafe: 
	UNSAFE=t $(MAKE) all-run

safe:
	UNSAFE=f $(MAKE) all-run

debug: safe

all-run:
	@if [ "$(PHP_EXT_LIST)" = "" ]; then echo "nothing to be done (all-run)."; else for d in "$(PHP_EXT_LIST)"; do \
           if [ -d $$d ]; then \
             export UNSAFE; \
             echo "making extension $$d ..."; \
             (cd $$d && $(MAKE) all-run); \
           fi; \
        done; \
      fi
# -- don't have any yet --        
#ifeq ($(PCC_OS),PCC_MINGW)
#	@for d in $(WIN_PHP_EXT_LIST); do \
#           if [ -d $$d ]; then \
#             export UNSAFE; \
#             echo "making windows only extension $$d ..."; \
#             (cd $$d && $(MAKE) all-run); \
#           fi \
#        done
#endif

tags:
	@if [ "$(PHP_EXT_LIST)" = "" ]; then echo "no tags to be done (tags)."; else for d in "$(PHP_EXT_LIST)"; do \
           if [ -d $$d ]; then \
             echo "tagging extension $$d ..."; \
             (cd $$d && $(MAKE) tags); \
           fi; \
        done; \
      fi
#ifeq ($(PCC_OS),PCC_MINGW)
#	@for d in $(WIN_PHP_EXT_LIST); do \
#           if [ -d $$d ]; then \
#             echo "tagging windows only extension $$d ..."; \
#             (cd $$d && $(MAKE) tags); \
#           fi \
#        done
#endif

apidocs:
	@if [ "$(PHP_EXT_LIST)" = "" ]; then echo "no docs to be done (apidocs)."; else for d in "$(PHP_EXT_LIST)"; do \
           if [ -d $$d ]; then \
             echo "apidoc'ing extension $$d ..."; \
             (cd $$d && $(MAKE) apidocs); \
           fi; \
        done; \
      fi
#	@for d in $(WIN_PHP_EXT_LIST); do \
#           if [ -d $$d ]; then \
#             echo "apidoc'ing windows only extension $$d ..."; \
#             (cd $$d && $(MAKE) apidocs); \
#           fi \
#        done

clean:
	@if [ "$(PHP_EXT_LIST)" = "" ]; then echo "no cleaning to be done (clean)."; else for d in "$(PHP_EXT_LIST)"; do \
           if [ -d $$d ]; then \
             echo "cleaning extension $$d ..."; \
             (cd $$d && $(MAKE) clean); \
           fi; \
        done; \
      fi
#ifeq ($(PCC_OS),PCC_MINGW)
#	@for d in $(WIN_PHP_EXT_LIST); do \
#           if [ -d $$d ]; then \
#             echo "cleaning windows only extension $$d ..."; \
#             (cd $$d && $(MAKE) clean); \
#           fi \
#        done
#endif

check:
	@if [ "$(PHP_EXT_LIST)" = "" ]; then echo "no checking to be done (check)."; else for d in "$(PHP_EXT_LIST)"; do \
           if [ -d $$d ]; then \
             echo "checking extension $$d ..."; \
             (cd $$d && $(MAKE) check); \
           fi; \
        done; \
      fi
