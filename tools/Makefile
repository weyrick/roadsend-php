#
# build,clean,check tools
#

PCC_ROOT = ..
include $(PCC_ROOT)/bigloo-rules.mk

all: unsafe

unsafe:
	UNSAFE=t make all-run

safe:
	UNSAFE=f make all-run

debug: safe

all-run: $(PCC_ROOT)/libs/libwebserver.$(SOEXT)
	@for d in $(TOOLS_LIST); do \
           if [ -d $$d ]; then \
             export UNSAFE; \
             echo "making runtime tool: $$d ..."; \
             (cd $$d && $(MAKE) all-run); \
           fi \
        done

clean:
	-(cd libwebserver && $(MAKE) clean)
	@for d in $(TOOLS_LIST); do \
           if [ -d $$d ]; then \
             echo "cleaning runtime tool: $$d ..."; \
             (cd $$d && $(MAKE) clean); \
           fi \
        done

$(PCC_ROOT)/libs/libwebserver.$(SOEXT):
	(cd libwebserver && \
         ./configure > configure.out && \
         rm configure.out && \
         $(MAKE) all && \
         $(MAKE) install)

