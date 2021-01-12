#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# suspend background updates for 4 hours because overkill. background updates
# start back up after a reboot automatically. 

# then, simply grab all available updates and install. 

echo "Checking for macOS updates, this might take a while, please be patient..."
/usr/sbin/softwareupdate --install --all
