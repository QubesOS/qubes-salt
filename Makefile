.DEFAULT_GOAL = get-sources
.SECONDEXPANSION:

DIST ?= fc32
VERSION := $(shell cat version)

FEDORA_SOURCES := https://src.fedoraproject.org/rpms/salt/raw/f$(subst fc,,$(DIST))/f/sources
SRC_FILES := \
            salt-$(VERSION).tar.gz \

BUILDER_DIR ?= ../..
SRC_DIR ?= qubes-src

SRC_URLS := \
            https://files.pythonhosted.org/packages/source/s/salt/salt-$(VERSION).tar.gz \

UNTRUSTED_SUFF := .UNTRUSTED

SHELL := bash

.PHONY: get-sources verify-sources clean clean-sources

ifeq ($(FETCH_CMD),)
$(error "You can not run this Makefile without having FETCH_CMD defined")
endif

%: %.sha512
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) -- $(filter %/$@,$(SRC_URLS))
	@sha512sum --status -c <(printf "$$(cat $<)  -\n") <$@$(UNTRUSTED_SUFF) || \
		{ echo "Wrong SHA512 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

get-sources: $(SRC_FILES)
	@true

verify-sources:
	@true

clean:
	@true

clean-sources:
	rm -f $(SRC_FILES) *$(UNTRUSTED_SUFF)

# This target is generating content locally from upstream project
# 'sources' file. Sanitization is done but it is encouraged to perform
# update of component in non-sensitive environnements to prevent
# any possible local destructions due to shell rendering
.PHONY: update-sources
update-sources:
	@$(BUILDER_DIR)/$(SRC_DIR)/builder-rpm/scripts/generate-hashes-from-sources $(FEDORA_SOURCES)
