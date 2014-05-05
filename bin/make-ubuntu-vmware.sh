#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CM=${CM:-nocm}
CM_VERSION=${CM_VERSION:-}
BUILDER_TYPE=${BUILDER_TYPE:-vmware-iso}

VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-vmware_desktop}
BOX_PROVIDER=${BOX_PROVIDER:-vmware_fusion}
BOX_OUTPUT_DIR=${BOX_OUTPUT_DIR:-${DIR}/../box/vmware}
BOX_SUFFIX=${BOX_SUFFIX:-$CM.box}

source ${DIR}/make-ubuntu.sh
