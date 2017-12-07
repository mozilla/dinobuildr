#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this script gets software updates from Apple. As you can see it's real complicated.  

echo "Checking for macOS updates, this might take a while, please be patient..."
$(which softwareupdate) --install --all
