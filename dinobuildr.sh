#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Written by Lucius Bono and Tristan Thomas

# This script grabs the latest config.py script from the dinobuilder
# Github repo (https://github.com/mozilla/dinobuildr). At this time,
# we blindly trust the master branch, but later we hope to put more
# elaborate checks in place to ensure that the script is legit.

# Accepts optional parameters that specifies the branch and manifest
# to build against.

branch=master
manifest=manifest.json

while :; do
    case $1 in
        -b|--branch) branch=$2
        shift
        ;;
        -m|--manifest) manifest=$2
        shift
        ;;
        *) break
    esac
    shift
done

if [ "$branch" != '' ]; then
    if [[ "$branch" =~ [^a-zA-Z0-9{-.}] ]]; then
        echo "********************************************************************"
        echo "Branch name must be numbers, letters, - and . only."
        exit 1
    fi
fi

if [ "$manifest" != '' ]; then
    if [[ "$manifest" =~ [^a-zA-Z0-9{._}] ]]; then
        echo "********************************************************************"
        echo "Manifest name must be numbers, letters, . and _ only"
        exit 1
    fi
fi

printf "\nPulling down dinobuildr from the [%s] branch on github and starting
the build!\n\n" "$branch"
build_script=$(curl -f https://raw.githubusercontent.com/mozilla/dinobuildr/"$branch"/config.py)
curl_status=$?

# If curl fails for some reason, we return it's non-zero exit code so that the
# script can fail in a predictable way.

if [ $curl_status -eq 0 ]; then
    if python -c "$build_script" -b "$branch" -m "$manifest"; then
        echo "Rebooting!"
        osascript -e 'tell app "System Events" to restart'
    else
        echo "********************************************************************"
        echo "HOUSTON WE HAVE A PROBLEM: Dinobuildr did not complete successfully."
        echo "Please review the error and run the this build again."
    fi
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
