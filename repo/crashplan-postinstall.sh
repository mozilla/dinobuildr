#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# shellcheck disable=SC2086

PRODUCT_TYPE="CrashPlanPROe"
VERSION_PATTERN="*"
MAC_FILENAME_END="Mac.dmg"
MAC_PATTERN="${PRODUCT_TYPE}_${VERSION_PATTERN}_${MAC_FILENAME_END}"

echo "$DINOPATH"
echo "$MAC_PATTERN"

DMG=$(find "$DINOPATH" | grep -i -E ${DINOPATH}/${MAC_PATTERN})

echo "$DMG"

USERINFO_PATH="${DINOPATH}/userInfo.sh"
CUSTOMPROS_PATH="${DINOPATH}/custom.properties"
INSTALLER="Install CrashPlan PROe.pkg"
INSTALLER_PATH="/Volumes/${PRODUCT_TYPE}/${INSTALLER}"

if [ -z "${DMG}" ] || [ ! -e "${DMG}" ]; then
echo "Expected to find file matching this pattern: ${MAC_PATTERN}_${MAC_FILENAME_END}"
fi

## eject
if [ -e /Volumes/${PRODUCT_TYPE} ]; then
    echo "Eject ${PRODUCT_TYPE}"
    hdiutil eject /Volumes/${PRODUCT_TYPE}
fi

## mount dmg
echo "Mount DMG."
hdiutil attach "${DMG}" 

## copy custom
DST="/Volumes/${PRODUCT_TYPE}/.Custom"
if [ -e "${DST}" ]; then
    rm -rf "${DST}"
fi

mkdir -v "${DST}"

cp -v "${USERINFO_PATH}" "${DST}"
cp -v "${CUSTOMPROS_PATH}" "${DST}"

## install
/usr/sbin/installer -pkg "${INSTALLER_PATH}" -target /

## eject
echo "Eject ${PRODUCT_TYPE}"
hdiutil eject "/Volumes/${PRODUCT_TYPE}"
