## common makefile variables for the packages subtree
include ../packages.mk

all: compiler runtime #prereqs

clean:
	-rm -rf $(BUILD_ROOT)
	-rm -f $(SELF_OUT_DIR)/roadsend-pcc*.bin
	-rm -f install-compiler.sh
	-rm -f install-runtime.sh
#	-rm -f install-prereqs.sh

###
### the compiler package
### ====================

compiler: install-compiler.sh
	@echo "Building compiler self-installer package."
	-rm -rf $(BUILD_ROOT)
	(cd $(PCC_HOME) && $(MAKE) docs)
	(cd $(PCC_HOME) && $(MAKE) INSTALL_ROOT=$(BUILD_ROOT)/install-root INSTALL_PREFIX=$(INSTALL_PREFIX) install)
	install -m 0755 -d $(BUILD_ROOT)
	install -m 0755 install-compiler.sh $(BUILD_ROOT)/install-compiler.sh
	$(MAKESELF) $(BUILD_ROOT) $(SELF_OUT_DIR)/roadsend-pcc-$(PCC_VERSION).bin \
		"The Roadsend PCC Compiler for PHP" ./install-compiler.sh

install-compiler.sh: install-compiler.sh.template
	@echo "Creating installer script for compiler self-installer package."
#	$(SCRIPT_DIR)/replace-tag-with-file.sh $(LICENSE_TAG) $(LICENSE_FILE) install-compiler.sh.template > install-compiler.sh
	cp install-compiler.sh.template install-compiler.sh

### 
### the runtime package
### ===================

runtime: install-runtime.sh
	@echo "Building runtime self-installer package."
	-rm -rf $(BUILD_ROOT)
	(cd $(PCC_HOME) && $(MAKE) INSTALL_ROOT=$(BUILD_ROOT)/install-root INSTALL_PREFIX=$(INSTALL_PREFIX) install-runtime)
	$(BIGLOO_INSTALLER) $(BIGLOO_SOURCE) $(BUILD_ROOT)/install-root $(INSTALL_PREFIX)
	install -m 0755 -d $(BUILD_ROOT)
	install -m 0755 install-runtime.sh $(BUILD_ROOT)/install-runtime.sh
	$(MAKESELF) $(BUILD_ROOT) $(SELF_OUT_DIR)/roadsend-pcc-runtime-$(PCC_VERSION).bin \
		"The Roadsend PCC Compiler for PHP - Runtime Environment" ./install-runtime.sh

install-runtime.sh: install-runtime.sh.template
	@echo "Creating installer script for runtime self-installer package."
#	$(SCRIPT_DIR)/replace-tag-with-file.sh $(LICENSE_TAG) $(LICENSE_FILE) install-runtime.sh.template > install-runtime.sh
	cp install-runtime.sh.template install-runtime.sh

###
### the prerequisites package
### =========================

# prereqs: install-prereqs.sh
# 	@echo "Building prereqs self-installer package."
# 	-rm -rf $(BUILD_ROOT)
# 	$(BIGLOO_INSTALLER) $(BIGLOO_SOURCE) $(BUILD_ROOT)/install-root $(INSTALL_PREFIX)
# 	$(BIGLIB_INSTALLER) $(BIGLIB_SOURCE) $(BUILD_ROOT)/install-root $(INSTALL_PREFIX) $(BIGLOO_VERSION)
# 	install -m 0755 -d $(BUILD_ROOT)
# 	install -m 0755 install-prereqs.sh $(BUILD_ROOT)/install-prereqs.sh
# 	$(MAKESELF) $(BUILD_ROOT) $(SELF_OUT_DIR)/roadsend-pcc-prereqs-$(PCC_VERSION).bin \
# 		"The Roadsend PCC Compiler for PHP - Prerequisites" ./install-prereqs.sh

# install-prereqs.sh: install-prereqs.sh.template
# 	@echo "Creating installer script for prereqs self-installer package."
# 	cp install-prereqs.sh.template install-prereqs.sh
