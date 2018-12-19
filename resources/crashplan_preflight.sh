#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

############
# This script moves the deploy.properties file into the main /Library 
# folder on the system, which as of CrashPlan version 6.9.0 is the best
# location for this file (and ~/Library wasn't working)

if [ ! -d /Library/Application\ Support/CrashPlan ]; then
    mkdir /Library/Application\ Support/CrashPlan
fi
    cp "${DINOPATH}/deploy.properties" "/Library/Application Support/CrashPlan"

