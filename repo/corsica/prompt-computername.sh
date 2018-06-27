#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

read -r -d '' applescriptCode <<'EOF'
   set hostnamePrompt to text returned of (display dialog "Enter desired hostname:" default answer "")
   return hostnamePrompt
EOF

hostname=$(osascript -e "$applescriptCode");

echo "Setting LocalHostName and ComputerName to ${hostname}"

scutil --set LocalHostName $hostname
scutil --set ComputerName $hostname
