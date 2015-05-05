#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error and immediately exit
set -o errexit # If a command fails exit the whole script

if [ "${DEBUG:-false}" = "true" ]; then
  set -x
fi

usage() {
    echo "usage: $(basename $0) <box_name> <box_suffix> <version>"
    echo
    echo "Requires the following environment variables to be set:"
    echo "  ATLAS_USERNAME"
    echo "  ATLAS_ACCESS_TOKEN"
}

args() {
    if [ $# -lt 3 ]; then
        usage
        exit 1
    fi

    if [ -z ${ATLAS_USERNAME+x} ]; then
        echo "ATLAS_USERNAME environment variable not set!"
        usage
        exit 1
    elif [ -z ${ATLAS_ACCESS_TOKEN+x} ]; then
        echo "ATLAS_ACCESS_TOKEN environment variable not set!"
        usage
        exit 1
    fi
    
    BOX_NAME=$1
    BOX_SUFFIX=$2
    VERSION=$3
}

get_short_description() {
    if [[ "${BOX_NAME}" =~ i386 ]]; then
        BIT_STRING="32-bit"
    else
        BIT_STRING="64-bit"
    fi
    DOCKER_STRING=
    if [[ "${BOX_NAME}" =~ docker ]]; then
        DOCKER_STRING=" with Docker preinstalled"
    fi
    EDITION_STRING=
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
        PRETTY_VERSION="14.04.2 LTS Trusty Tahr"
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
    SHORT_DESCRIPTION="Ubuntu${EDITION_STRING} ${PRETTY_VERSION} (${BIT_STRING})${DOCKER_STRING}"
}

create_description() {
    if [[ "${BOX_NAME}" =~ i386 ]]; then
        BIT_STRING="32-bit"
    else
        BIT_STRING="64-bit"
    fi
    DOCKER_STRING=
    if [[ "${BOX_NAME}" =~ docker ]]; then
        DOCKER_STRING=" with Docker preinstalled"
    fi
    EDITION_STRING=
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
        PRETTY_VERSION="14.04.2 LTS Trusty Tahr"
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

    if [[ -e ${VMWARE_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

VMware Tools ${VMWARE_VERSION}"
    fi
    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

VirtualBox Guest Additions ${VIRTUALBOX_VERSION}"
    fi
    if [[ -e ${PARALLELS_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

Parallels Tools ${PARALLELS_VERSION}"
    fi

    VERSION_JSON=$(
      jq -n "{
        version: {
          version: \"${VERSION}\",
          description: \"${DESCRIPTION}\"
        }
      }"
    )
}

publish_provider() {
    echo "==> Checking to see if ${PROVIDER} provider exists"
    HTTP_STATUS=$(curl -s -f -o /dev/nul -w "%{http_code}" -i "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}/version/${VERSION}/provider/${PROVIDER}"?access_token="${ATLAS_ACCESS_TOKEN}" || true)
    echo ${HTTP_STATUS}
    if [ 200 -eq ${HTTP_STATUS} ]; then
        echo "==> Updating ${PROVIDER} provider"
        curl -X PUT "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}/version/${VERSION}/provider/${PROVIDER}" -d "access_token=${ATLAS_ACCESS_TOKEN}" -d provider[name]="${PROVIDER}" -d provider[url]="${PROVIDER_URL}"
    else
        echo "==> Creating ${PROVIDER} provider"
        curl -X POST "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}/version/${VERSION}/providers" -d "access_token=${ATLAS_ACCESS_TOKEN}" -d provider[name]="${PROVIDER}" -d provider[url]="${PROVIDER_URL}"
    fi
}


main() {
    args "$@"

    ATLAS_API_URL=https://atlas.hashicorp.com/api/v1

    echo "==> Checking for existing box ${BOX_NAME}"
    # Retrieve box
    HTTP_STATUS=$(curl -s -f -o /dev/nul -w "%{http_code}" -i "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}"?access_token="${ATLAS_ACCESS_TOKEN}" || true)
    if [ 404 -eq ${HTTP_STATUS} ]; then
        echo "${BOX_NAME} does not exist, creating"
        get_short_description

        curl -X POST "${ATLAS_API_URL}/boxes" -d box[name]="${BOX_NAME}" -d box[short_description]="${SHORT_DESCRIPTION}" -d box[is_private]=false -d "access_token=${ATLAS_ACCESS_TOKEN}"
    elif [ 200 -ne ${HTTP_STATUS} ]; then
        echo "Unknown status ${HTTP_STATUS} from box/get" && exit 1
    fi

    echo "==> Checking for existing version ${VERSION}"
    # Retrieve version
    HTTP_STATUS=$(curl -s -f -o /dev/nul -w "%{http_code}" -i "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}/version/${VERSION}" || true)
    if [ 404 -ne ${HTTP_STATUS} ] && [ 200 -ne ${HTTP_STATUS} ]; then
        echo "Unknown HTTP status ${HTTP_STATUS} from version/get" && exit 1
    fi

    create_description
    #echo "${VERSION_JSON}"
    if [ 404 -eq ${HTTP_STATUS} ]; then
       echo "==> none found; creating"
       JSON_RESULT=$(curl -s -f -X POST -H "Content-Type: application/json" "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}/versions?access_token=${ATLAS_ACCESS_TOKEN}" -d "${VERSION_JSON}" || true)
    else
       echo "==> version found; updating"
       JSON_RESULT=$(curl -s -f -X PUT "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}/version/${VERSION}" -d "access_token=${ATLAS_ACCESS_TOKEN}" -d "version[description]=${DESCRIPTION}" || true)
    fi

    BOXCUTTER_BASE_URL=http://cdn.boxcutter.io/ubuntu
    if [[ -e ${VMWARE_BOX_FILE} ]]; then
        PROVIDER=vmware_desktop
        PROVIDER_URL=${BOXCUTTER_BASE_URL}/vmware${VMWARE_VERSION}/${BOX_NAME}${BOX_SUFFIX}
        publish_provider
    fi
    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        PROVIDER=virtualbox
        PROVIDER_URL=${BOXCUTTER_BASE_URL}/virtualbox${VIRTUALBOX_VERSION}/${BOX_NAME}${BOX_SUFFIX}
        publish_provider
    fi
    if [[ -e ${PARALLELS_BOX_FILE} ]]; then
        PROVIDER=parallels
        PROVIDER_URL=${BOXCUTTER_BASE_URL}/parallels${PARALLELS_VERSION}/${BOX_NAME}${BOX_SUFFIX}
        publish_provider
    fi

    echo
    STATUS=$(echo ${JSON_RESULT} | jq -r .status)
    case $STATUS in
    unreleased)
      curl -X PUT "${ATLAS_API_URL}/box/${ATLAS_USERNAME}/${BOX_NAME}/version/${VERSION}/release" -d "access_token=${ATLAS_ACCESS_TOKEN}"
      echo 'released!'
      ;;
    active)
      echo 'already released'
      ;;
    *)
      abort "cannot publish version with status '$STATUS'"
esac
}

main "$@"
