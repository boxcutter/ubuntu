#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CM=${CM:-nocm}
CM_VERSION=${CM_VERSION:-}
BUILDER_TYPE=${BUILDER_TYPE:-vmware-iso}

VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-vmware_desktop}
BOX_PROVIDER=${BOX_PROVIDER:-vmware_fusion}
BOX_OUTPUT_DIR=${BOX_OUTPUT_DIR:-${DIR}/../box/vmware}
BOX_SUFFIX=${BOX_SUFFIX:-$CM.box}

if [[ -f iso_url.local.cfg ]]; then
    source ${DIR}/iso_url.local.cfg
else
    source ${DIR}/iso_url.cfg
fi

source ${DIR}/test-box.sh

cleanup()
{
    rm -rf output-$BUILDER_TYPE
    rm -f ~/.ssh/known_hosts
}
pushd ${DIR}/..
#pushd $HOME/github/misheska/basebox-packer/template/ubuntu

cleanup
packer build -only=$BUILDER_TYPE -var "iso_url=$UBUNTU1004_SERVER_I386" -var "cm=$CM" -var "cm_version=$CM_VERSION" ubuntu1004-i386.json
test_box $BOX_OUTPUT_DIR/ubuntu1004-i386-$BOX_SUFFIX $BOX_PROVIDER

cleanup
packer build -only=$BUILDER_TYPE -var "iso_url=$UBUNTU1004_SERVER_AMD64" -var "cm=$CM" -var "cm_version=$CM_VERSION" ubuntu1004.json
test_box $BOX_OUTPUT_DIR/ubuntu1004-$BOX_SUFFIX $BOX_PROVIDER

cleanup
packer build -only=$BUILDER_TYPE -var "iso_url=$UBUNTU1204_SERVER_I386" -var "cm=$CM" -var "cm_version=$CM_VERSION" ubuntu1204-i386.json
test_box $BOX_OUTPUT_DIR/ubuntu1204-i386-$BOX_SUFFIX $BOX_PROVIDER

cleanup
packer build -only=$BUILDER_TYPE -var "iso_url=$UBUNTU1204_ALTERNATE_AMD64" -var "cm=$CM" -var "cm_version=$CM_VERSION" ubuntu1204-desktop.json
test_box $BOX_OUTPUT_DIR/ubuntu1204-desktop-$BOX_SUFFIX $BOX_PROVIDER

for t in ubuntu1204-docker ubuntu1204
do
    cleanup
    packer build -only=$BUILDER_TYPE -var "iso_url=$UBUNTU1204_SERVER_AMD64" -var "cm=$CM" -var "cm_version=$CM_VERSION" $t.json
    test_box $BOX_OUTPUT_DIR/$t-$BOX_SUFFIX $BOX_PROVIDER
done

cleanup
packer build -only=$BUILDER_TYPE -var "iso_url=$UBUNTU1404_SERVER_I386" -var "cm=$CM" -var "cm_version=$CM_VERSION" ubuntu1404-i386.json
test_box $BOX_OUTPUT_DIR/ubuntu1404-i386-$BOX_SUFFIX $BOX_PROVIDER

for t in ubuntu1404-docker ubuntu1404 ubuntu1404-desktop
do
    cleanup
    packer build -only=$BUILDER_TYPE -var "iso_url=$UBUNTU1404_SERVER_AMD64" -var "cm=$CM" -var "cm_version=$CM_VERSION" $t.json
    test_box $BOX_OUTPUT_DIR/$t-$BOX_SUFFIX $BOX_PROVIDER
done

cleanup

popd
