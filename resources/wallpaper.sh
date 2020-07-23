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

WALLPAPER_FILENAME=wallpaper-firefox.png

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

echo "Copying ${DINOPATH}/${WALLPAPER_FILENAME} to /Users/Shared/${WALLPAPER_FILENAME}"
cp "${DINOPATH}/${WALLPAPER_FILENAME}" "/Users/Shared/${WALLPAPER_FILENAME}"

# If we're running on 10.13 or below, we can use the old Applescript method to
# set the background. 
# If we're on 10.14 or above, we use Steve Ward's method for setting the
# wallpaper by pulling down a specific commit of their script from Github. 
# We also check the hash of that pinned commit just to be sure. 

if [[ "$os_version" -le "10" && "$major_version" -le "13" ]]; then
    echo "Since this is a pre-Mojave machine, we are setting the wallpaper the old-fashioned way."
    /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/'"$WALLPAPER_FILENAME"'"'

elif [[ "$os_version" -eq "10" && "$major_version" -eq "14" ]]; then
    WALLPAPER_SH=$(curl -fsSL https://raw.githubusercontent.com/mozilla/macos-desktop/810e38873c9c4d63b9d4b35cc81c008c88eac1ca/set-desktop-mojave.sh)
    HASH="1b6f7b016731119a83350130a7aef751f8ce5261b494a83a5ecfad3c76b39e02" # change only after thorough testing

    if [ "$(echo "$WALLPAPER_SH" | shasum -a 256 | awk '{print $1}')" == $HASH ]; then #  if the hashes match then proceed
        echo "We're on Mojave so we're going to use the Mojave way to set the wallpaper."
        /bin/bash -c "$WALLPAPER_SH" -s "/Users/Shared/$WALLPAPER_FILENAME"
    fi

elif [[ "$os_version" -eq "10" && "$major_version" -eq "15" ]]; then
    WALLPAPER_SH=$(curl -fsSL https://raw.githubusercontent.com/mozilla/macos-desktop/810e38873c9c4d63b9d4b35cc81c008c88eac1ca/set-desktop-catalina.sh)
    HASH="a5fd5700616730f3db1af48bf380156a1897197108be359a3c7769b7a359d7c9" # change only after thorough testing

    if [ "$(echo "$WALLPAPER_SH" | shasum -a 256 | awk '{print $1}')" == $HASH ]; then #  if the hashes match then proceed
        echo "We're on Catalina so we're going to use the Mojave way to set the wallpaper."
        /bin/bash -c "$WALLPAPER_SH" -s "/Users/Shared/$WALLPAPER_FILENAME"
    fi       
else 
    echo "Wallpaper script hash does not match intended value or something else went wrong. Aborting."
    exit 1
fi

