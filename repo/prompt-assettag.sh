#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script will set the hostname of a macOS machine to a cominbation of the
# logged in user name + the asset tag of the machine. It will prompt the user or
# the technician to enter the asset tag, validate the input to make sure it is a
# six digit numerical asset tag and will reprompt if the input is not validated.

# Get the user the usual way

user=`python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");'`

# Prompt the user or the tech for the asset tag number

assetnumber=$(
    /usr/bin/osascript <<-"EOF"
		set hostnamePrompt to text returned of (display dialog "Enter Mozilla asset tag:" default answer "")
		return hostnamePrompt
    EOF
)

# Validate the input with a do-while loop, making sure that we only have six
# digits.

while true; do
    if [[ ! "$assetnumber" =~ ^[0-9]{6}$ ]]; then
        assetnumber=$(
            /usr/bin/osascript <<-"EOF"
				set hostnamePrompt to text returned of (display dialog "Invalid entry. Please enter a six digit Mozilla asset tag:" default answer "")
				return hostnamePrompt
            EOF
        )
        continue
    else
        break 1
    fi
done

# Construct the hostname via the username + asset tag

hostname="${user}-${assetnumber}"

echo "Setting LocalHostName and ComputerName to ${hostname}"

# Do the actual work

scutil --set LocalHostName $hostname 
scutil --set ComputerName $hostname
