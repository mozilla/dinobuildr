#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script creates a AppleScript and LaunchAgent under the corsica user.
# The LaunchAgent launches the AppleScript at login and the AppleScript
# launches Firefox in fullscreen mode.

cat > /Users/Shared/launch-firefox.applescript <<- "EOF"
tell application "Firefox"
	activate
	delay 5
	tell application "System Events" to keystroke "f"
end tell
EOF

cat > /Library/LaunchAgents/launch-firefox.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>launch-firefox</string>
    <key>ProgramArguments</key>
    <array>
    	<string>/usr/bin/osascript</string>
        <string>/Users/Shared/launch-firefox.applescript</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
