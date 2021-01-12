#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this script checks for a minimum OS version and is intended to halt the build
# if the machine does not meet that minimum version

# minimum_os - OS family version
# minimum_major - minimum major version (15 = Catalina)
# minimum_minor - minimum minor version

# minimum is Catalina 10.15.0

minimum_os="10"
minimum_major="15"
minimum_minor="0"

os_version=$(sw_vers -productVersion | awk -F '.' '{print $1}')
major_version=$(sw_vers -productVersion | awk -F '.' '{print $2}')
minor_version=$(sw_vers -productVersion | awk -F '.' '{print $3}')

if [[ "$minor_version" -eq '' ]]; then
    minor_version=0
fi

if ! [[ "$os_version" -ge "$minimum_os" ]]; then
    if ! [[ "$os_version" -eq "$minimum_os" && "$major_version" -ge "$minimum_major" ]]; then
        echo "UPGRADE REQUIRED: You are running macOS ${os_version}.${major_version}.${minor_version}"
        echo "We are expecting at least: ${minimum_os}.${minimum_major}.${minimum_minor}"
        echo "The build will halt, please update macOS via the App Store and try again."
        exit 1
    fi
else
    echo "You are running macOS ${os_version}.${major_version}.${minor_version}, which meets the minimum requirements."
    exit 0
fi
