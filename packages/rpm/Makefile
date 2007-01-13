## common makefile variables for the packages subtree
include ../packages.mk

COMPILER_RPM_NAME = roadsend-pcc-$(PCC_VERSION)-1.*.rpm 
RUNTIME_RPM_NAME  = roadsend-pcc-runtime-$(PCC_VERSION)-1.*.rpm
PREREQS_RPM_NAME  = roadsend-pcc-prereqs-$(PCC_VERSION)-1.*.rpm

all: warning #compiler runtime prereqs

warning:
	echo "this is broken, it needs to be fixed to work like selfs. ask GRiD"

clean:
	-rm -f $(RPM_OUT_DIR)/roadsend-pcc*.rpm
	-rm -f $(RPM_OUT_DIR)/roadsend-pcc*.rpm.sh
	-rm -f roadsend-pcc.spec
	-rm -f roadsend-pcc-runtime.spec
	-rm -f roadsend-pcc-prereqs.spec
	-rm -f install-compiler-rpm.sh
	-rm -f install-runtime-rpm.sh
	-rm -f install-prereqs-rpm.sh
	-rm -rf $(BUILD_OUT_DIR)

###
### the compiler package
### ====================

# compiler: compiler-rpm install-compiler-rpm.sh
# 	@echo "Building compiler rpm-self-installer package."
# 	-rm -rf $(BUILD_ROOT)
# 	mkdir -p $(BUILD_ROOT)
# 	mv $(RPM_OUT_DIR)/$(COMPILER_RPM_NAME) $(BUILD_ROOT)
# 	install --mode=755 install-compiler-rpm.sh $(BUILD_ROOT)/install-compiler-rpm.sh
# 	$(MAKESELF) --bzip2 $(BUILD_ROOT) $(RPM_OUT_DIR)/roadsend-pcc-$(PCC_VERSION).rpm.sh \
# 		"The Roadsend PCC Compiler for PHP" ./install-compiler-rpm.sh

# install-compiler-rpm.sh: install-compiler-rpm.sh.template
# 	@echo "Creating installer script for compiler rpm-self-installer package."
# 	$(SCRIPT_DIR)/replace-tag-with-file.sh $(LICENSE_TAG) $(LICENSE_FILE) install-compiler-rpm.sh.template > install-compiler-rpm.sh	

compiler: roadsend-pcc.spec
	@echo "Building compiler rpm package."
	-rm -rf $(BUILD_ROOT)
	(cd $(PCC_HOME) && make INSTALL_ROOT=$(BUILD_ROOT) INSTALL_PREFIX=$(INSTALL_PREFIX) install)
	rpmbuild -bb roadsend-pcc.spec
	mv $(RPM_DB_DIR)/RPMS/i*86/$(COMPILER_RPM_NAME) $(RPM_OUT_DIR)

roadsend-pcc.spec: roadsend-pcc.spec.template
	@echo "Creating spec file for compiler rpm package."
	cat roadsend-pcc.spec.template | sed 's/$(PCC_VERSION_TAG)/$(PCC_VERSION)/g' | \
	sed 's%$(BUILD_ROOT_TAG)%$(BUILD_ROOT)%g' > roadsend-pcc.spec

### 
### the runtime package
### ===================

# runtime: runtime-rpm install-runtime-rpm.sh
# 	@echo "Building runtime rpm-self-installer package."
# 	-rm -rf $(BUILD_ROOT)
# 	mkdir -p $(BUILD_ROOT)
# 	mv $(RPM_OUT_DIR)/$(RUNTIME_RPM_NAME) $(BUILD_ROOT)
# 	install --mode=755 install-runtime-rpm.sh $(BUILD_ROOT)/install-runtime-rpm.sh
# 	$(MAKESELF) --bzip2 $(BUILD_ROOT) $(RPM_OUT_DIR)/roadsend-pcc-runtime-$(PCC_VERSION).rpm.sh \
# 		"The Roadsend PCC Compiler for PHP - Runtime Environment" ./install-runtime-rpm.sh

# install-runtime-rpm.sh: install-runtime-rpm.sh.template
# 	@echo "Creating installer script for runtime rpm-self-installer package."
# 	$(SCRIPT_DIR)/replace-tag-with-file.sh $(LICENSE_TAG) $(LICENSE_FILE) install-runtime-rpm.sh.template > install-runtime-rpm.sh	

runtime: roadsend-pcc-runtime.spec
	@echo "Building runtime rpm package."
	-rm -rf $(BUILD_ROOT)
	(cd $(PCC_HOME) && make INSTALL_ROOT=$(BUILD_ROOT) INSTALL_PREFIX=$(INSTALL_PREFIX) install-runtime)
	rpmbuild -bb roadsend-pcc-runtime.spec
	mv $(RPM_DB_DIR)/RPMS/i*86/$(RUNTIME_RPM_NAME) $(RPM_OUT_DIR)

roadsend-pcc-runtime.spec: roadsend-pcc-runtime.spec.template
	@echo "Creating spec file for runtime rpm package."
	cat roadsend-pcc-runtime.spec.template | sed 's/$(PCC_VERSION_TAG)/$(PCC_VERSION)/g' | \
	sed 's%$(BUILD_ROOT_TAG)%$(BUILD_ROOT)%g' > roadsend-pcc-runtime.spec

###
### the prerequisites package
### =========================

prereqs: roadsend-pcc-prereqs.spec
	@echo "Building prereqs rpm package."
	-rm -rf $(BUILD_ROOT)
	$(BIGLOO_INSTALLER) $(BIGLOO_SOURCE) $(BUILD_ROOT) $(INSTALL_PREFIX)
	$(BIGLIB_INSTALLER) $(BIGLIB_SOURCE) $(BUILD_ROOT) $(INSTALL_PREFIX) $(BIGLOO_VERSION)
	rpmbuild -bb roadsend-pcc-prereqs.spec
	mv $(RPM_DB_DIR)/RPMS/i*86/$(PREREQS_RPM_NAME) $(RPM_OUT_DIR)

roadsend-pcc-prereqs.spec: roadsend-pcc-prereqs.spec.template
	@echo "Creating spec file for prereqs rpm package."
	cat roadsend-pcc-prereqs.spec.template | sed 's/$(PCC_VERSION_TAG)/$(PCC_VERSION)/g' | \
	sed 's%$(BUILD_ROOT_TAG)%$(BUILD_ROOT)%g' > roadsend-pcc-prereqs.spec
