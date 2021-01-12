#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this script checks for machine processor architecture and
# installs rosetta 2 for arm systems

processor_architecture=$(uname -p)
if [[ "$processor_architecture" = 'arm' ]]; then
    echo "Installing Rosetta 2 for Arm system"
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    exit 0
else
    echo "You are using the ${processor_architecture} architecture, Rosetta not needed."
    exit 0
fi