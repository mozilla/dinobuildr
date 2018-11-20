#/bin/bash

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

# Set the filename of the wallpaper file

WALLPAPER_FILENAME=wallpaper.jpg

# Determine which version of macOS we're running

os_version=$(sw_vers -productVersion | awk -F '.' '{print $1}')
major_version=$(sw_vers -productVersion | awk -F '.' '{print $2}')
minor_version=$(sw_vers -productVersion | awk -F '.' '{print $3}')

if [[ "$minor_version" -eq $null ]]; then
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
    $(which osascript) -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/'"$WALLPAPER_FILENAME"'"'
else

    WALLPAPER_SH=$(curl -sc - https://raw.githubusercontent.com/tech-otaku/macos-desktop/3e29f30853552e2288c56699b3214ecff6fed44b/set-desktop-mojave.sh)
    HASH="e42761c63203225ba46e9e460ea07b23738bc5e3a5b19d425a6314688a445d4b" # change only after thorough testing

    if [ $(echo "$WALLPAPER_SH" | shasum -a 256 | awk {'print $1'}) == $HASH ]; then #  if the hashes match then proceed
        echo "We're on Mojave (or newer) so we're going to pull down Steve Ward's method for setting the wallpaper."
        /bin/bash -c "$WALLPAPER_SH" -s "/Users/Shared/$WALLPAPER_FILENAME"
        
    else 
        echo "Wallpaper script hash does not match intended value. Aborting."
        exit 1
    fi
fi
