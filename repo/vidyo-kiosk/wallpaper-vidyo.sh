#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this script copies a wall-paper image from the temp build cache to a permanent
# location and uses Applescript to set the desktop background. 

WALLPAPER_FILENAME='High Sierra.jpg'
cp "${DINOPATH}/$WALLPAPER_FILENAME" "/Library/Destkop Pictures/$WALLPAPER_FILENAME"
echo "We're setting the dang wallpaper now."
