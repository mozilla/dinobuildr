#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# dockutil is created by kcrawford and is licensed under the Apache 2.0
# license. please see https://github.com/kcrawford/dockutil for more
# details. 

# This script configured the dock in macOS using dockutil. It does not
# install dockutil, it loads the script from a specfic github commit
# that has been tested and hashed by Mozilla IT. NOTE: Do not change
# the hash or the url without testing.

hash="c49ba68db90f7ac3a50a490e597078df6de6a8feba16c24ccced7b34d84f705e" # change only after thorough testing
dockutil=$(curl -fsSL https://raw.githubusercontent.com/kcrawford/dockutil/b7fcec8aae863cd83cb27c2cf8bd3e739ece0795/scripts/dockutil)

if [ $(echo "$dockutil" | shasum -a 256 | awk {'print $1'}) == $hash ]; then #  if the hashes match then proceed
    echo "Executing dockutil - hash matches expected value."
    python -c "$dockutil" --remove all --no-restart
    python -c "$dockutil" --add "/Applications/Launchpad.app" --position beginning --no-restart
    python -c "$dockutil" --add "/Applications/Firefox.app" --after Launchpad --no-restart
    python -c "$dockutil" --add "/Applications/VidyoDesktop.app" --after Firefox --no-restart
    python -c "$dockutil" --add "/Applications/Crashplan.app" --after VidyoDesktop --no-restart
    python -c "$dockutil" --add "/Applications/System Preferences.app" --position end
else 
    echo "Dockutil hash does not match intended value. Aborting."
    exit 1
fi
