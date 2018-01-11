#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script disables the screensaver while dinobuildr is running
# and creates a LaunchAgent. The LaunchAgents runs at the next login
# and re-enables the screensaver to start after five minutes and 
# then self-destructs.

user=`python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");'`

sudo -u ${user} defaults -currentHost write com.apple.screensaver idleTime 0

mkdir ~/Library/LaunchAgents
chown ${user} ~/Library/LaunchAgents

cat > ~/Library/LaunchAgents/Enable_Screensaver.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>EnableScreensaver</string>
    <key>ProgramArguments</key>
    <array>
        <string>bash</string>
        <string>-c</string>
        <string>defaults -currentHost write com.apple.screensaver idleTime 300;
        rm -rf ~/Library/LaunchAgents/Enable_Screensaver.plist</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

chown ${user} ~/Library/LaunchAgents/Enable_Screensaver.plist