#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this script copies a wall-paper image from the temp build cache to a permanent
# location and then either pulls down Steve Ward's excellent script for setting the
# wallpaper in macOS Mojave, or uses the old tried and true Applescript method
# of setting the wallpaper, depending on the OS version this script is being run
# on.
#
# You can see Steve's script the follow github repo: https://github.com/tech-otaku/macos-desktop
# 
# We fork the repo so that we can ensure that we have access to a version of
# this project. 
# 
# Set the filename of the wallpaper file

WALLPAPER_FILENAME=wallpaper.jpg

# Determine which version of macOS we're running

os_version=$(sw_vers -productVersion | awk -F '.' '{print $1}')
major_version=$(sw_vers -productVersion | awk -F '.' '{print $2}')
minor_version=$(sw_vers -productVersion | awk -F '.' '{print $3}')

if [[ "$minor_version" -eq '' ]]; then
    minor_version=0
fi

# Copy the wallpaper file to /User/Shared. $DINOPATH is an environment variable
# that dinobuildr itself actually sets in case we change the working directory
# in the future. 

cp "${DINOPATH}/$WALLPAPER_FILENAME" "/Users/Shared/$WALLPAPER_FILENAME"

# If we're running on 10.13 or below, we can use the old Applescript method to
# set the background. 
# If we're on 10.14 or above, we use Steve Ward's method for setting the
# wallpaper by pulling down a specific commit of their script from Github. 
# We also check the hash of that pinned commit just to be sure. 

if [[ "$os_version" -le "10" && "$major_version" -le "13" ]]; then
    echo "Since this is a pre-Mojave machine, we are setting the wallpaper the old-fashioned way."
    /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/'"$WALLPAPER_FILENAME"'"'
else
    WALLPAPER_SH=$(curl -fsSL https://raw.githubusercontent.com/mozilla/macos-desktop/abfb607953e0c789bb8e853ec28f545e89ddebbe/set-desktop-mojave.sh)
    HASH="50b049f9cf9a57582fa83f411b66c61fed854f553102c05ca91cbd249cdb9ac8" # change only after thorough testing

    if [ "$(echo "$WALLPAPER_SH" | shasum -a 256 | awk '{print $1}')" == $HASH ]; then #  if the hashes match then proceed
        echo "We're on Mojave (or newer) so we're going to use the new way to set the wallpaper."
        /bin/bash -c "$WALLPAPER_SH" -s "/Users/Shared/$WALLPAPER_FILENAME"
        
    else 
        echo "Wallpaper script hash does not match intended value. Aborting."
        exit 1
    fi
fi

