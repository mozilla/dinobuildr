#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Written by Lucius Bono and Tristan Thomas

# This script grabs the latest config.py script from the dinobuilder
# Github repo (https://github.com/mozilla/dinobuildr). At this time,
# we blindly trust the master branch, but later we hope to put more
# elaborate checks in place to ensure that the script is legit.

# Accepts an option parameter that specifies the name of the branch we want to
# use (defaults to master).

branch=${1:-master}

printf "\nPulling down dinobuildr from the [$branch] branch on github and starting the build!\n\n"
build_script=$(curl -f https://raw.githubusercontent.com/mozilla/dinobuildr/$branch/config.py)
curl_status=$?
# If curl fails for some reason, we return it's non-zero exit code so that the
# script can fail in a predictable way.

if [ $curl_status -eq 0 ]; then
    echo "$build_script" | python -
else 
    echo "********************************************************************"
    echo "Uh oh, unable to download Dinobuildr from Github."
    if [ $curl_status -eq 6 ]; then
        echo "Check your internet connection and try again!"
    elif [ $curl_status -eq 22 ]; then
        echo "$branch is not a valid branch. Please verify the branch name and try again."
    fi
    exit 1
fi

# After the build is complete, we reboot so that any updates that
# were installed can finish up. 

# Of course, this fails if there was any issues.

if [ $? -eq 0 ]; then
    echo "Rebooting!"
    osascript -e 'tell app "System Events" to restart'
else
    echo "********************************************************************"
    echo "HOUSTON WE HAVE A PROBLEM: Dinobuildr did not complete successfully."
    echo "Please review the error and run the this build again."
fi
