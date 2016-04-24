#!/bin/bash

echo "==> Checking version of Ubuntu"
. /etc/lsb-release

case "$DISTRIB_RELEASE" in
    16.04)
        echo "==> Fixing LANG locale value (necessary on $DISTRIB_RELEASE)"
        update-locale LANG=en_US.UTF-8
        ;;
    *)
        echo "==> Fixing LANG not necessary on $DISTRIB_RELEASE"
        ;;
esac
