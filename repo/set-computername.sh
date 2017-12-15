#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script sets the LocalHostName and the ComputerName on a machine using
# the following naming convention: [username]-[last 6 digits of the serial
# number]. We also make sure the we don't use any capital letters because
# Tristan hates them. 

lastSNdigits=$(system_profiler SPHardwareDataType |
               grep 'Serial Number (system)' | 
               awk '{print $NF}' | 
               tail -c 7)
user=`python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");'`
hostname="${user}-"${lastSNdigits}""
hostname=$(echo $hostname | tr '[:upper:]' '[:lower:]')

echo "Setting LocalHostName and ComputerName to ${hostname}"

scutil --set LocalHostName $hostname
scutil --set ComputerName $hostname
