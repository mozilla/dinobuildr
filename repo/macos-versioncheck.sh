#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this script checks for a minimum OS version and is intended to halt the build
# if the machine does not meet that minimum version

# expected_os - OS family version
# expected_major - expected major version (13 = High Sierra, etc)
# expected_minor - expected minor version

expected_os="10"
expected_major="13"
expected_minor="3"

os_version=$(sw_vers -productVersion | awk -F '.' '{print $1}')
major_version=$(sw_vers -productVersion | awk -F '.' '{print $2}')
minor_version=$(sw_vers -productVersion | awk -F '.' '{print $3}')

if [[ "$minor_version" -eq $null ]]; then
    minor_version=0
fi

if ! [[ "$os_version" -ge "$expected_os" && "$major_version" -ge "$expected_major" ]]; then
    if ! [[ "$major_version" -gt "$expected_major" ]]; then
        echo "UPGRADE REQUIRED: You are running macOS ${os_version}.${major_version}.${minor_version}"
        echo "We are expecting: ${expected_os}.${expected_major}.${expected_minor}"
        echo "The build will halt, please update macOS via the App Store and try again."
        exit 1
    fi
else
    echo "You are running macOS ${os_version}.${major_version}.${minor_version}, which meets the minimum requirements."
    exit 0
fi
