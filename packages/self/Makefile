## common makefile variables for the packages subtree
include ../packages.mk

all: compiler runtime

clean:
	-rm -rf $(BUILD_ROOT)
	-rm -f $(SELF_OUT_DIR)/roadsend-pcc*.bin
	-rm -f install-compiler.sh
	-rm -f install-runtime.sh

###
### the compiler package
### ====================

compiler: install-compiler.sh
	@echo "Building compiler self-installer package."
	-rm -rf $(BUILD_ROOT)
	(cd $(PCC_HOME) && $(MAKE) docs)
	(cd $(PCC_HOME) && $(MAKE) INSTALL_ROOT=$(BUILD_ROOT)/install-root INSTALL_PREFIX=$(INSTALL_PREFIX) package-install)
	install -m 0755 -d $(BUILD_ROOT)
	install -m 0755 install-compiler.sh $(BUILD_ROOT)/install-compiler.sh
	$(MAKESELF) $(BUILD_ROOT) $(SELF_OUT_DIR)/roadsend-pcc-$(PCC_VERSION).bin \
		"Roadsend PHP" ./install-compiler.sh

install-compiler.sh: install-compiler.sh.template
	@echo "Creating installer script for compiler self-installer package."
	cp install-compiler.sh.template install-compiler.sh

### 
### the runtime package
### ===================

runtime: install-runtime.sh
	@echo "Building runtime self-installer package."
	-rm -rf $(BUILD_ROOT)
	(cd $(PCC_HOME) && $(MAKE) INSTALL_ROOT=$(BUILD_ROOT)/install-root INSTALL_PREFIX=$(INSTALL_PREFIX) package-install-runtime)
	$(BIGLOO_INSTALLER) $(BIGLOO_SOURCE) $(BUILD_ROOT)/install-root $(INSTALL_PREFIX)
	install -m 0755 -d $(BUILD_ROOT)
	install -m 0755 install-runtime.sh $(BUILD_ROOT)/install-runtime.sh
	$(MAKESELF) $(BUILD_ROOT) $(SELF_OUT_DIR)/roadsend-pcc-runtime-$(PCC_VERSION).bin \
		"Roadsend PHP - Runtime Environment" ./install-runtime.sh

install-runtime.sh: install-runtime.sh.template
	@echo "Creating installer script for runtime self-installer package."
	cp install-runtime.sh.template install-runtime.sh

