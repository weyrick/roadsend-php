## directory where rpm keeps its package "database"
RPM_DB_DIR	= /usr/src/rpm

## current version of bigloo
BIGLOO_VERSION	= 2.6f

## current version of pcc
PCC_VERSION	= $(shell $(PCC_HOME)/compiler/pcc --version)

## path to the bigloo source directory
BIGLOO_SOURCE	= $(HOME)/bigloo/bigloo$(BIGLOO_VERSION)

########################################################################

## the top level of the packages subtree
PACKAGES_ROOT	= $(PCC_HOME)/packages

## the prefix directory we want everything installed into (e.g. /usr)
## -- currently this is also hardcoded in the output in the *.template files in selfs/
INSTALL_PREFIX	= /opt/roadsend/pcc

## directory to place the rpm files in
RPM_OUT_DIR	= $(PACKAGES_ROOT)

## directory to place the deb files in
DEB_OUT_DIR	= $(PACKAGES_ROOT)

## directory to place the self-installer files in
SELF_OUT_DIR	= $(PACKAGES_ROOT)

## text string to be replaced by the pcc version in various files
PCC_VERSION_TAG = PCC_VERSION_HERE

## path of the license file
LICENSE_FILE	= $(PACKAGES_ROOT)/LICENSE

## text string to be replaced by the license in various install scripts
LICENSE_TAG	= LICENSE_HERE

## temporary directory where packages get built (note that this directory
## will be removed! don't set it to your homedir or anything)
BUILD_ROOT	= /tmp/roadsend-pcc-build-root

## text string to be replaced by the build-root directory in various files
BUILD_ROOT_TAG	= BUILD_ROOT_HERE

## the directory containing common scripts for the packages
SCRIPT_DIR	= $(PACKAGES_ROOT)/scripts

## the retargetable installer script for bigloo
BIGLOO_INSTALLER	= $(SCRIPT_DIR)/install-bigloo-$(BIGLOO_VERSION).sh

## path to the makeself script
MAKESELF	= $(SCRIPT_DIR)/makeself/makeself.sh

