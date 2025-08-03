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
            https://github.com/saltstack/salt/releases/download/v$(VERSION)/salt-$(VERSION).tar.gz \

UNTRUSTED_SUFF := .UNTRUSTED

SHELL := bash

.PHONY: get-sources verify-sources clean clean-sources

ifeq ($(FETCH_CMD),)
$(error "You can not run this Makefile without having FETCH_CMD defined")
endif

keyring := salt-trustedkeys.gpg
keyring-file := $(if $(GNUPGHOME), $(GNUPGHOME)/, $(HOME)/.gnupg/)$(keyring)
keyring-import := gpg -q --no-auto-check-trustdb --no-default-keyring --import

$(keyring-file): SALT-PROJECT-GPG-PUBKEY-2023.pub
	@rm -f $(keyring-file) && $(keyring-import) --keyring $(keyring) $^

#salt-%.tar.gz.asc:
#	@$(FETCH_CMD) $@ $(filter %/$(patsubst %.asc,%,$@),$(SRC_URLS)).asc

%: %.asc $(keyring-file)
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(filter %/$@,$(SRC_URLS))
	@gpgv --keyring $(keyring) $< $@$(UNTRUSTED_SUFF) 2>/dev/null || \
		{ echo "Wrong signature on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@
	
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
