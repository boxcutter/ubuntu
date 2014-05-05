#!/bin/bash -eux

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BUILDER_TYPE=${BUILDER_TYPE:-virtualbox-iso}
CM=${CM:-nocm}
CM_VERSION=${CM_VERSION:-}

VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-virtualbox}
BOX_PROVIDER=${BOX_PROVIDER:-virtualbox}
BOX_OUTPUT_DIR=${BOX_OUTPUT_DIR:-${DIR}/../box/virtualbox}
BOX_SUFFIX=${BOX_SUFFIX:-$CM.box}

source ${DIR}/make-ubuntu.sh
