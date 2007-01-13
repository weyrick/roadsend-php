## common makefile variables for the packages subtree
include ../packages.mk

all: warning #compiler runtime prereqs

warning:
	echo "this is broken, it needs to be fixed to work like selfs. ask GRiD"

clean:
	-rm -f $(DEB_OUT_DIR)/roadsend-pcc*.deb
	-rm -f roadsend-pcc*.control
	-rm -f roadsend-pcc*.preinst
	-rm -f roadsend-pcc*.postinst
	-rm -f roadsend-pcc*.postrm

###
### the compiler package
### ====================

compiler: roadsend-pcc.control roadsend-pcc.preinst roadsend-pcc.postinst roadsend-pcc.postrm
	@echo "Building compiler deb package."
	rm -rf $(BUILD_ROOT)
	install --mode=644 -D roadsend-pcc.control $(BUILD_ROOT)/DEBIAN/control
	install --mode=755 -D roadsend-pcc.preinst $(BUILD_ROOT)/DEBIAN/preinst
	install --mode=755 -D roadsend-pcc.postinst $(BUILD_ROOT)/DEBIAN/postinst
	install --mode=755 -D roadsend-pcc.postrm $(BUILD_ROOT)/DEBIAN/postrm
	(cd $(PCC_HOME) && make INSTALL_ROOT=$(BUILD_ROOT) INSTALL_PREFIX=$(INSTALL_PREFIX) install)
	dpkg-deb -b $(BUILD_ROOT) $(DEB_OUT_DIR)/roadsend-pcc_$(PCC_VERSION)-1_i386.deb

roadsend-pcc.control: roadsend-pcc.control.template
	@echo "Creating control file for compiler deb package."
	cat roadsend-pcc.control.template | sed 's/$(PCC_VERSION_TAG)/$(PCC_VERSION)/g' > roadsend-pcc.control

roadsend-pcc.preinst: roadsend-pcc.preinst.template
	@echo "Creating preinstall script for compiler deb package."
#	$(SCRIPT_DIR)/replace-tag-with-file.sh $(LICENSE_TAG) $(LICENSE_FILE) roadsend-pcc.preinst.template > roadsend-pcc.preinst
	cp roadsend-pcc.preinst.template roadsend-pcc.preinst

roadsend-pcc.postinst: roadsend-pcc.postinst.template
	@echo "Creating postinstall script for compiler deb package."
	cp roadsend-pcc.postinst.template roadsend-pcc.postinst

roadsend-pcc.postrm: roadsend-pcc.postrm.template
	@echo "Creating postremoval script for compiler deb package."
	cp roadsend-pcc.postrm.template roadsend-pcc.postrm

### 
### the runtime package
### ===================

runtime: roadsend-pcc-runtime.control roadsend-pcc-runtime.preinst roadsend-pcc-runtime.postinst roadsend-pcc-runtime.postrm
	@echo "Building runtime deb package."
	rm -rf $(BUILD_ROOT)
	install --mode=644 -D roadsend-pcc-runtime.control $(BUILD_ROOT)/DEBIAN/control
	install --mode=755 -D roadsend-pcc-runtime.preinst $(BUILD_ROOT)/DEBIAN/preinst
	install --mode=755 -D roadsend-pcc-runtime.postinst $(BUILD_ROOT)/DEBIAN/postinst
	install --mode=755 -D roadsend-pcc-runtime.postrm $(BUILD_ROOT)/DEBIAN/postrm
	(cd $(PCC_HOME) && make INSTALL_ROOT=$(BUILD_ROOT) INSTALL_PREFIX=$(INSTALL_PREFIX) install-runtime)
	dpkg-deb -b $(BUILD_ROOT) $(DEB_OUT_DIR)/roadsend-pcc-runtime_$(PCC_VERSION)-1_i386.deb

roadsend-pcc-runtime.control: roadsend-pcc-runtime.control.template
	@echo "Creating control file for runtime deb package."
	cat roadsend-pcc-runtime.control.template | sed 's/$(PCC_VERSION_TAG)/$(PCC_VERSION)/g' > roadsend-pcc-runtime.control

roadsend-pcc-runtime.preinst: roadsend-pcc-runtime.preinst.template
	@echo "Creating preinstall script for runtime deb package."
#	$(SCRIPT_DIR)/replace-tag-with-file.sh $(LICENSE_TAG) $(LICENSE_FILE) roadsend-pcc-runtime.preinst.template > roadsend-pcc-runtime.preinst
	cp roadsend-pcc-runtime.preinst.template roadsend-pcc-runtime.preinst

roadsend-pcc-runtime.postinst: roadsend-pcc-runtime.postinst.template
	@echo "Creating postinstall script for runtime deb package."
	cp roadsend-pcc-runtime.postinst.template roadsend-pcc-runtime.postinst

roadsend-pcc-runtime.postrm: roadsend-pcc-runtime.postrm.template
	@echo "Creating postremoval script for runtime deb package."
	cp roadsend-pcc-runtime.postrm.template roadsend-pcc-runtime.postrm

###
### the prerequisites package
### =========================

prereqs: roadsend-pcc-prereqs.control roadsend-pcc-prereqs.postinst roadsend-pcc-prereqs.postrm
	@echo "Building prereqs deb package."
	rm -rf $(BUILD_ROOT)
	install --mode=644 -D roadsend-pcc-prereqs.control $(BUILD_ROOT)/DEBIAN/control
	install --mode=755 -D roadsend-pcc-prereqs.postinst $(BUILD_ROOT)/DEBIAN/postinst
	install --mode=755 -D roadsend-pcc-prereqs.postrm $(BUILD_ROOT)/DEBIAN/postrm
	$(BIGLOO_INSTALLER) $(BIGLOO_SOURCE) $(BUILD_ROOT) $(INSTALL_PREFIX)
	$(BIGLIB_INSTALLER) $(BIGLIB_SOURCE) $(BUILD_ROOT) $(INSTALL_PREFIX) $(BIGLOO_VERSION)
	dpkg-deb -b $(BUILD_ROOT) $(DEB_OUT_DIR)/roadsend-pcc-prereqs_$(PCC_VERSION)-1_i386.deb

roadsend-pcc-prereqs.control: roadsend-pcc.control.template
	@echo "Creating control file for prereqs deb package."
	cat roadsend-pcc-prereqs.control.template | sed 's/$(PCC_VERSION_TAG)/$(PCC_VERSION)/g' > roadsend-pcc-prereqs.control

roadsend-pcc-prereqs.postinst: roadsend-pcc-prereqs.postinst.template
	@echo "Creating postinstall script for prereqs deb package."
	cp roadsend-pcc-prereqs.postinst.template roadsend-pcc-prereqs.postinst

roadsend-pcc-prereqs.postrm: roadsend-pcc-prereqs.postrm.template
	@echo "Creating postremoval script for prereqs deb package."
	cp roadsend-pcc-prereqs.postrm.template roadsend-pcc-prereqs.postrm
