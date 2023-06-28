RPM_SPEC_FILES.dom0-fc37 := salt.spec
RPM_SPEC_FILES.vm-fc37 := salt.spec
RPM_SPEC_FILES.vm-fc38 := salt.spec
DEBIAN_BUILD_DIRS.vm-bookworm = debian-pkg/debian

RPM_SPEC_FILES := $(RPM_SPEC_FILES.$(PACKAGE_SET)-$(DIST))
DEBIAN_BUILD_DIRS := $(DEBIAN_BUILD_DIRS.$(PACKAGE_SET)-$(DIST))

NO_ARCHIVE := 1

SOURCE_COPY_IN.debian := source-debian-copy-in
SOURCE_COPY_IN.qubuntu := source-debian-copy-in
SOURCE_COPY_IN := $(SOURCE_COPY_IN.$(DISTRIBUTION))

source-debian-copy-in: VERSION = $(file <$(ORIG_SRC)/version)
source-debian-copy-in: ORIG_FILE = $(CHROOT_DIR)/$(DIST_SRC)/salt_$(VERSION).orig.tar.gz
source-debian-copy-in: SRC_FILE  = $(ORIG_SRC)/salt-$(VERSION).tar.gz
source-debian-copy-in:
	cp -p $(SRC_FILE) $(ORIG_FILE)
	tar xzf $(SRC_FILE) -C $(CHROOT_DIR)/$(DIST_SRC)/debian-pkg --strip-components=1
