# Possible values for CM: (nocm | chef | chefdk | salt | puppet)
CM ?= nocm
# Possible values for CM_VERSION: (latest | x.y.z | x.y)
CM_VERSION ?=
ifndef CM_VERSION
	ifneq ($(CM),nocm)
		CM_VERSION = latest
	endif
endif
BOX_VERSION ?= $(shell cat VERSION)
ifeq ($(CM),nocm)
	BOX_SUFFIX := -$(CM)-$(BOX_VERSION).box
else
	BOX_SUFFIX := -$(CM)$(CM_VERSION)-$(BOX_VERSION).box
endif

BUILDER_TYPES ?= vmware virtualbox parallels
TEMPLATE_FILENAMES := $(filter-out ubuntu.json ubuntu1510.json,$(wildcard *.json))
BOX_NAMES := $(basename $(TEMPLATE_FILENAMES)) ubuntu1510
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
VMWARE_BOX_DIR ?= box/vmware
VMWARE_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
VMWARE_BOX_FILENAMES := $(VMWARE_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
VMWARE_BOX_FILES := $(foreach box_filename, $(VMWARE_BOX_FILENAMES), $(VMWARE_BOX_DIR)/$(box_filename))
VIRTUALBOX_BOX_DIR ?= box/virtualbox
VIRTUALBOX_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
VIRTUALBOX_BOX_FILENAMES := $(VIRTUALBOX_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
VIRTUALBOX_BOX_FILES := $(foreach box_filename, $(VIRTUALBOX_BOX_FILENAMES), $(VIRTUALBOX_BOX_DIR)/$(box_filename)) box/virtualbox/ubuntu1510$(BOX_SUFFIX)
PARALLELS_BOX_DIR ?= box/parallels
PARALLELS_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
PARALLELS_BOX_FILENAMES := $(PARALLELS_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
PARALLELS_BOX_FILES := $(foreach box_filename, $(PARALLELS_BOX_FILENAMES), $(PARALLELS_BOX_DIR)/$(box_filename)) box/parallels/ubuntu1510$(BOX_SUFFIX)
BOX_FILES := $(VMWARE_BOX_FILES) $(VIRTUALBOX_BOX_FILES) $(PARALLELS_BOX_FILES)

box/vmware/%$(BOX_SUFFIX) box/virtualbox/%$(BOX_SUFFIX) box/parallels/%$(BOX_SUFFIX): %.json
	bin/box build $<

box/vmware/ubuntu1510$(BOX_SUFFIX): ubuntu1510.json
	packer build -only=vmware-iso -var "version=$(BOX_VERSION)" $<

box/virtualbox/ubuntu1510$(BOX_SUFFIX): ubuntu1510.json
	packer build -only=virtualbox-iso -var "version=$(BOX_VERSION)" $<

box/parallels/ubuntu1510$(BOX_SUFFIX): ubuntu1510.json
	packer build -only=parallels-iso -var "version=$(BOX_VERSION)" $<

.PHONY: all clean assure deliver assure_atlas assure_atlas_vmware assure_atlas_virtualbox assure_atlas_parallels

all: build assure deliver

build: $(BOX_FILES)

assure: assure_vmware assure_virtualbox assure_parallels

assure_vmware: $(VMWARE_BOX_FILES)
	@for vmware_box_file in $(VMWARE_BOX_FILES) ; do \
		echo Checking $$vmware_box_file ; \
		bin/box test $$vmware_box_file vmware ; \
	done

assure_virtualbox: $(VIRTUALBOX_BOX_FILES)
	@for virtualbox_box_file in $(VIRTUALBOX_BOX_FILES) ; do \
		echo Checking $$virtualbox_box_file ; \
		bin/box test $$virtualbox_box_file virtualbox ; \
	done

assure_parallels: $(PARALLELS_BOX_FILES)
	@for parallels_box_file in $(PARALLELS_BOX_FILES) ; do \
		echo Checking $$parallels_box_file ; \
		bin/box test $$parallels_box_file parallels ; \
	done

assure_atlas: assure_atlas_vmware assure_atlas_virtualbox assure_atlas_parallels

assure_atlas_vmware:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-vagrantcloud-box box-cutter/$$box_name vmware ; \
		bin/test-vagrantcloud-box boxcutter/$$box_name vmware ; \
	done

assure_atlas_virtualbox:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-vagrantcloud-box box-cutter/$$box_name virtualbox ; \
		bin/test-vagrantcloud-box boxcutter/$$box_name virtualbox ; \
	done

assure_atlas_parallels:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-vagrantcloud-box box-cutter/$$box_name parallels ; \
		bin/test-vagrantcloud-box boxcutter/$$box_name parallels ; \
	done

deliver:
	@for box_name in $(BOX_NAMES) ; do \
		echo Uploading $$box_name to Atlas ; \
		bin/register_atlas.sh $$box_name $(BOX_SUFFIX) $(BOX_VERSION) ; \
	done

clean:
	@for builder in $(BUILDER_TYPES) ; do \
		echo Deleting output-*-$$builder-iso ; \
		echo rm -rf output-*-$$builder-iso ; \
	done
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d box/$$builder ; then \
			echo Deleting box/$$builder/*.box ; \
			find box/$$builder -maxdepth 1 -type f -name "*.box" ! -name .gitignore -exec rm '{}' \; ; \
		fi ; \
	done

