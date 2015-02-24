#!/usr/bin/env bash

set -eux

BOX_NAME=$1
BOX_SUFFIX=$2
VERSION=$3

ATLAS_URI=https://atlas.hashicorp.com/api/v1/box/${ATLAS_USERNAME}

callGETService() {
    local uri=$1

    echo "Calling URI (GET): " ${uri}
    curl -X GET "${uri}" --output "${COMM_FILE}" 2> /dev/null > "${COMM_FILE}"
}

COMM_FILE_DIR=$(pwd)/.tmpatlas
mkdir -p ${COMM_FILE_DIR}
COMM_FILE=${COMM_FILE_DIR}/atlas_comm.json

echo "==> Checking for existing version"
callGETService ${ATLAS_URI}/${BOX_NAME}?${ATLAS_ACCESS_TOKEN}

existing_version=$(jq -r ".versions[] | select(.version == \"${VERSION}\") | .version" < ${COMM_FILE})

if [[ "${BOX_NAME}" =~ i386 ]]; then
    BIT_STRING="32-bit"
else
    BIT_STRING="64-bit"
fi
DOCKER_STRING=
if [[ "${BOX_NAME}" =~ docker ]]; then
    DOCKER_STRING=" with Docker preinstalled"
fi
DESKTOP_STRING=
if [[ "${BOX_NAME}" =~ desktop ]]; then
    EDITION_STRING=" Desktop"
else
    EDITION_STRING=" Server"
fi
RAW_VERSION=${BOX_NAME#ubuntu}
RAW_VERSION=${RAW_VERSION%-i386}
RAW_VERSION=${RAW_VERSION%-docker}
RAW_VERSION=${RAW_VERSION%-desktop}
PRETTY_VERSION=${RAW_VERSION:0:2}.${RAW_VERSION:2}
case ${PRETTY_VERSION} in
15.04)
    PRETTY_VERSION="15.04 Vivid Vervet"
    ;;
14.10)
    PRETTY_VERSION="14.10 Utopic Unicorn"
    ;;
14.04)
    PRETTY_VERSION="14.04.1 LTS Trusty Tahr"
    ;;
12.04)
    PRETTY_VERSION="12.04.5 LTS Precise Pangolin"
    ;;
10.04)
    PRETTY_VERSION="10.04.4 LTS Lucid Lynx"
    ;;
esac

VIRTUALBOX_VERSION=$(virtualbox --help | head -n 1 | awk '{print $NF}')
PARALLELS_VERSION=$(prlctl --version | awk '{print $3}')
VMWARE_VERSION=9.9.2

VMWARE_BOX_FILE=box/vmware/${BOX_NAME}${BOX_SUFFIX}
VIRTUALBOX_BOX_FILE=box/virtualbox/${BOX_NAME}${BOX_SUFFIX}
PARALLELS_BOX_FILE=box/parallels/${BOX_NAME}${BOX_SUFFIX}
DESCRIPTION="Ubuntu${EDITION_STRING} ${PRETTY_VERSION} (${BIT_STRING})${DOCKER_STRING}, "
if [[ -e ${VMWARE_BOX_FILE} ]]; then
    FILESIZE=$(du -k -h "${VMWARE_BOX_FILE}" | cut -f1)
    DESCRIPTION=${DESCRIPTION}"VMWare ${FILESIZE}B/"
fi
if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
    FILESIZE=$(du -k -h "${VIRTUALBOX_BOX_FILE}" | cut -f1)
    DESCRIPTION=${DESCRIPTION}"VirtualBox ${FILESIZE}B/"
fi
if [[ -e ${PARALLELS_BOX_FILE} ]]; then
    FILESIZE=$(du -k -h "${PARALLELS_BOX_FILE}" | cut -f1)
    DESCRIPTION=${DESCRIPTION}"Parallels ${FILESIZE}B/"
fi
DESCRIPTION=${DESCRIPTION%?}
echo ${DESCRIPTION} > ${COMM_FILE_DIR}/description
if [[ -e ${VMWARE_BOX_FILE} ]]; then
    echo >> ${COMM_FILE_DIR}/description
    echo "VMware Tools ${VMWARE_VERSION}" >> ${COMM_FILE_DIR}/description
fi
if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
    echo >> ${COMM_FILE_DIR}/description
    echo "VirtualBox Guest Additions ${VIRTUALBOX_VERSION}" >> ${COMM_FILE_DIR}/description
fi
if [[ -e ${PARALLELS_BOX_FILE} ]]; then
    echo >> ${COMM_FILE_DIR}/description
    echo "Parallels Tools ${PARALLELS_VERSION}" >> ${COMM_FILE_DIR}/description
fi

description_json="null"
if [ -n "${COMM_FILE_DIR}/description" ]; then
    description_json=$(jq -s -R . < ${COMM_FILE_DIR}/description)
fi
version_file=VERSION
version_json=$(
    jq -n "{
      version: {
        version: $(jq -R . < $version_file),
        description: ${description_json}
      }
    }"
)

token_param="access_token=${ATLAS_ACCESS_TOKEN}"
echo ${version_json}
if [ -z "${existing_version}" ]; then
  echo "==> none found; creating"
  curl -X POST -H "Content-Type: application/json" ${ATLAS_URI}/${BOX_NAME}/versions?${token_param} -d "$version_json" > ${COMM_FILE_DIR}/version_result.json
else
  echo "==> version found; updating"
  curl -X PUT -H "Content-Type: application/json" ${ATLAS_URI}/${BOX_NAME}/version/${VERSION}?${token_param} -d "$version_json" > ${COMM_FILE_DIR}/version_result.json
fi

status=$(jq -r .status < ${COMM_FILE_DIR}/version_result.json)

echo 'publishing provider'
BOXCUTTER_BASE_URL=http://cdn.boxcutter.io/ubuntu
if [[ -e ${VMWARE_BOX_FILE} ]]; then
    PROVIDER_URL=${BOXCUTTER_BASE_URL}/vmware${VMWARE_VERSION}/${BOX_NAME}${BOX_SUFFIX}
    PROVIDER=vmware_desktop
    echo ${PROVIDER_URL}
    curl -X POST ${ATLAS_URI}/${BOX_NAME}/version/${VERSION}/providers -d "${token_param}" -d provider[name]="${PROVIDER}" -d provider[url]="${PROVIDER_URL}" > ${COMM_FILE_DIR}/provider_result.json
fi
if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
    PROVIDER=virtualbox
    PROVIDER_URL=${BOXCUTTER_BASE_URL}/virtualbox${VIRTUALBOX_VERSION}/${BOX_NAME}${BOX_SUFFIX}
    echo ${PROVIDER_URL}
    curl -X POST ${ATLAS_URI}/${BOX_NAME}/version/${VERSION}/providers -d "${token_param}" -d provider[name]="${PROVIDER}" -d provider[url]="${PROVIDER_URL}" > ${COMM_FILE_DIR}/provider_result.json
fi
if [[ -e ${PARALLELS_BOX_FILE} ]]; then
    PROVIDER_URL=${BOXCUTTER_BASE_URL}/parallels${PARALLELS_VERSION}/${BOX_NAME}${BOX_SUFFIX}
    PROVIDER=parallels
    curl -X POST ${ATLAS_URI}/${BOX_NAME}/version/${VERSION}/providers -d "${token_param}" -d provider[name]="${PROVIDER}" -d provider[url]="${PROVIDER_URL}" > ${COMM_FILE_DIR}/provider_result.json
fi

case $status in
unreleased)
  curl -X PUT ${ATLAS_URI}/${BOX_NAME}/version/${VERSION}/release -d ${token_param}
  echo 'released!'
  ;;
active)
  echo 'already released'
  ;;
*)
  abort "cannot publish version with status '$status'"
esac
rm -rf ${COMM_FILE_DIR}
