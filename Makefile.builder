ifneq ($(DIST), fc25)
RPM_SPEC_FILES.dom0 := salt.spec
endif

RPM_SPEC_FILES := $(RPM_SPEC_FILES.$(PACKAGE_SET))
NO_ARCHIVE := 1
