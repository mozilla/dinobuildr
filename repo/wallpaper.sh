#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this script copies a wall-paper image from the temp build cache to a permanent
# location and uses Applescript to set the desktop background. 

cp "${DINOPATH}/dino-wallpaper.png" "/Users/Shared/dino-wallpaper.png"
echo "We're setting the dang wallpaper now."
$(which osascript) -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/dino-wallpaper.png"'
