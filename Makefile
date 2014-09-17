# if Makefile.local exists, include it
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif

PACKER_VERSION = $(shell packer --version | sed 's/^.* //g' | sed 's/^.//')
ifneq (0.5.0, $(word 1, $(sort 0.5.0 $(PACKER_VERSION))))
$(error Packer version less than 0.5.x, please upgrade)
endif

UBUNTU1004_SERVER_AMD64 ?= http://releases.ubuntu.com/10.04.4/ubuntu-10.04.4-server-amd64.iso
UBUNTU1004_SERVER_I386 ?= http://releases.ubuntu.com/10.04.4/ubuntu-10.04.4-server-i386.iso
UBUNTU1204_SERVER_AMD64 ?= http://releases.ubuntu.com/12.04/ubuntu-12.04.5-server-amd64.iso
UBUNTU1204_SERVER_I386 ?= http://releases.ubuntu.com/12.04/ubuntu-12.04.5-server-i386.iso
UBUNTU1204_ALTERNATE_AMD64 ?= http://releases.ubuntu.com/12.04/ubuntu-12.04.4-alternate-amd64.iso
UBUNTU1304_SERVER_AMD64 ?= http://releases.ubuntu.com/13.04/ubuntu-13.04-server-amd64.iso
UBUNTU1304_SERVER_I386 ?= http://releases.ubuntu.com/13.04/ubuntu-13.04-server-i386.iso
UBUNTU1310_SERVER_AMD64 ?= http://releases.ubuntu.com/13.10/ubuntu-13.10-server-amd64.iso
UBUNTU1310_SERVER_I386 ?= http://releases.ubuntu.com/13.10/ubuntu-13.10-server-i386.iso
UBUNTU1404_SERVER_AMD64 ?= http://releases.ubuntu.com/14.04/ubuntu-14.04.1-server-amd64.iso
UBUNTU1404_SERVER_I386 ?= http://releases.ubuntu.com/14.04/ubuntu-14.04.1-server-i386.iso

# Possible values for CM: (nocm | chef | chefdk | salt | puppet)
CM ?= nocm
# Possible values for CM_VERSION: (latest | x.y.z | x.y)
CM_VERSION ?=
ifndef CM_VERSION
	ifneq ($(CM),nocm)
		CM_VERSION = latest
	endif
endif
HEADLESS ?=
BOX_VERSION ?= $(shell cat VERSION)
ifeq ($(CM),nocm)
	BOX_SUFFIX := -$(CM)-$(BOX_VERSION).box
else
	BOX_SUFFIX := -$(CM)$(CM_VERSION)-$(BOX_VERSION).box
endif
# Packer does not allow empty variables, so only pass variables that are defined
ifdef CM_VERSION
	PACKER_VARS := -var 'cm=$(CM)' -var 'cm_version=$(CM_VERSION)' -var 'headless=$(HEADLESS)' -var 'update=$(UPDATE)' -var 'version=$(BOX_VERSION)'
else
	PACKER_VARS := -var 'cm=$(CM)' -var 'headless=$(HEADLESS)' -var 'update=$(UPDATE)' -var 'version=$(BOX_VERSION)'
endif
ifdef PACKER_DEBUG
	PACKER := PACKER_LOG=1 packer --debug
else
	PACKER := packer
endif
BUILDER_TYPES := vmware virtualbox
TEMPLATE_FILENAMES := $(wildcard *.json)
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), box/$(builder)/$(box_filename)))
TEST_BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), test-box/$(builder)/$(box_filename)))
VMWARE_BOX_DIR := box/vmware
VIRTUALBOX_BOX_DIR := box/virtualbox
VMWARE_OUTPUT := output-vmware-iso
VIRTUALBOX_OUTPUT := output-virtualbox-iso
VMWARE_BUILDER := vmware-iso
VIRTUALBOX_BUILDER := virtualbox-iso
CURRENT_DIR = $(shell pwd)
SOURCES := $(wildcard script/*.sh) $(floppy/*.*) $(http/*.cfg)

.PHONY: all list clean validate

all: $(BOX_FILES)

test: $(TEST_BOX_FILES)

###############################################################################
# Target shortcuts
define SHORTCUT

vmware/$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-vmware/$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-vmware/$(1): ssh-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

virtualbox/$(1): $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-virtualbox/$(1): test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

ssh-virtualbox/$(1): ssh-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

$(1): vmware/$(1) virtualbox/$(1)

test-$(1): test-vmware/$(1) test-virtualbox/$(1)

endef

SHORTCUT_TARGETS := ubuntu1004-i386 ubuntu1004 ubuntu1204-desktop ubuntu1204-docker ubuntu1204-i386 ubuntu1204 ubuntu1404-desktop ubuntu1404-docker ubuntu1404-i386 ubuntu1404
$(foreach i,$(SHORTCUT_TARGETS),$(eval $(call SHORTCUT,$(i))))

###############################################################################

# Generic rule - not used currently
#$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): %.json
#	cd $(dir $<)
#	rm -rf output-vmware-iso
#	mkdir -p $(VMWARE_BOX_DIR)
#	$(PACKER) build -only=vmware-iso $(PACKER_VARS) $<

$(VMWARE_BOX_DIR)/ubuntu1004-i386$(BOX_SUFFIX): ubuntu1004-i386.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1004_SERVER_I386)" $<

$(VMWARE_BOX_DIR)/ubuntu1004$(BOX_SUFFIX): ubuntu1004.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1004_SERVER_AMD64)" $<

$(VMWARE_BOX_DIR)/ubuntu1204-desktop$(BOX_SUFFIX): ubuntu1204-desktop.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_ALTERNATE_AMD64)" $<

$(VMWARE_BOX_DIR)/ubuntu1204-docker$(BOX_SUFFIX): ubuntu1204-docker.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_SERVER_AMD64)" $<

$(VMWARE_BOX_DIR)/ubuntu1204-i386$(BOX_SUFFIX): ubuntu1204-i386.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_SERVER_I386)" $<

$(VMWARE_BOX_DIR)/ubuntu1204$(BOX_SUFFIX): ubuntu1204.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_SERVER_AMD64)" $<

$(VMWARE_BOX_DIR)/ubuntu1404-desktop$(BOX_SUFFIX): ubuntu1404-desktop.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_AMD64)" $<

$(VMWARE_BOX_DIR)/ubuntu1404-docker$(BOX_SUFFIX): ubuntu1404-docker.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_AMD64)" $<

$(VMWARE_BOX_DIR)/ubuntu1404-i386$(BOX_SUFFIX): ubuntu1404-i386.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_I386)" $<

$(VMWARE_BOX_DIR)/ubuntu1404$(BOX_SUFFIX): ubuntu1404.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_AMD64)" $<

# Generic rule - not used currently
#$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): %.json
#	cd $(dir $<)
#	rm -rf output-virtualbox-iso
#	mkdir -p $(VIRTUALBOX_BOX_DIR)
#	$(PACKER) build -only=virtualbox-iso $(PACKER_VARS) $<
	
$(VIRTUALBOX_BOX_DIR)/ubuntu1004-i386$(BOX_SUFFIX): ubuntu1004-i386.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1004_SERVER_I386)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1004$(BOX_SUFFIX): ubuntu1004.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1004_SERVER_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1204-desktop$(BOX_SUFFIX): ubuntu1204-desktop.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_ALTERNATE_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1204-docker$(BOX_SUFFIX): ubuntu1204-docker.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_SERVER_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1204-i386$(BOX_SUFFIX): ubuntu1204-i386.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_SERVER_I386)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1204$(BOX_SUFFIX): ubuntu1204.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1204_SERVER_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1404-desktop$(BOX_SUFFIX): ubuntu1404-desktop.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1404-docker$(BOX_SUFFIX): ubuntu1404-docker.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1404-i386$(BOX_SUFFIX): ubuntu1404-i386.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_I386)" $<

$(VIRTUALBOX_BOX_DIR)/ubuntu1404$(BOX_SUFFIX): ubuntu1404.json $(SOURCES)
	cd $(dir $<)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(UBUNTU1404_SERVER_AMD64)" $<

list:
	@echo "Prepend 'vmware/' to build only vmware target:"
	@echo "  make vmware/ubuntu1404"
	@echo "Prepend 'virtualbox/' to build only virtualbox target:"
	@echo "  make virtualbox/ubuntu1404"
	@echo ""
	@echo "Targets:"
	@for shortcut_target in $(SHORTCUT_TARGETS) ; do \
		echo $$shortcut_target ; \
	done

validate:
	@for template_filename in $(TEMPLATE_FILENAMES) ; do \
		echo Checking $$template_filename ; \
		packer validate $$template_filename ; \
	done


clean: clean-builders clean-output clean-packer-cache
		
clean-builders:
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d box/$$builder ; then \
			echo Deleting box/$$builder/*.box ; \
			find box/$$builder -maxdepth 1 -type f -name "*.box" ! -name .gitignore -exec rm '{}' \; ; \
		fi ; \
	done
	
clean-output:
	@for builder in $(BUILDER_TYPES) ; do \
		echo Deleting output-$$builder-iso ; \
		echo rm -rf output-$$builder-iso ; \
	done
	
clean-packer-cache:
	echo Deleting packer_cache
	rm -rf packer_cache

test-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< vmware_desktop vmware_fusion $(CURRENT_DIR)/test/*_spec.rb
	
test-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	rm -f ~/.ssh/known_hosts
	bin/test-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb
	
ssh-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< vmware_desktop vmware_fusion $(CURRENT_DIR)/test/*_spec.rb
	
ssh-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	rm -f ~/.ssh/known_hosts
	bin/ssh-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb	
