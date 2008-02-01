#
# build,clean,check tools
#

PCC_ROOT = ..
include $(PCC_ROOT)/bigloo-rules.mk


all: $(PCC_ROOT)/libs/libwebserver.$(SOEXT)
	@for d in $(TOOLS_LIST); do \
           if [ -d $$d ]; then \
             echo "making runtime tool: $$d ..."; \
             (cd $$d && $(MAKE) all); \
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

