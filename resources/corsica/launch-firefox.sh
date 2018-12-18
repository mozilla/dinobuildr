#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script creates a LaunchAgent and LaunchDaemon. The LaunchAgent 
# launches Firefox in fullscreen mode under the corsica user at login. 
# The LaunchDaemon prevents Firefox from automatically relaunching
# after a reboot, shutdown, or power outage. The LaunchDaemon also
# clears the previous Firefox session before Firefox launches again.

cat > /Users/Shared/move-launch-firefox.sh <<- "EOF"
#!/bin/bash

if [ ! -d /Users/corsica/Library/LaunchAgents ]; then
    mkdir /Users/corsica/Library/LaunchAgents
    chown corsica /Users/corsica/Library/LaunchAgents
fi
 
mv /Users/Shared/launch-firefox.plist /Users/corsica/Library/LaunchAgents/launch-firefox.plist
chown corsica /Users/corsica/Library/LaunchAgents/launch-firefox.plist

chown -R corsica:staff /Applications/Firefox.app/

rm -rf /Library/LaunchDaemons/move-launch-firefox.plist

rm -rf "$0"
EOF

chmod +x /Users/Shared/move-launch-firefox.sh

cat > /Library/LaunchDaemons/move-launch-firefox.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>move-launch-firefox</string>
    <key>Program</key>
    <string>/Users/Shared/move-launch-firefox.sh</string>
    <key>WatchPaths</key>
    <array>
        <string>/Users/corsica/Library</string>
    </array>
</dict>
</plist>
EOF

cat > /Users/Shared/launch-firefox.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>launch-firefox</string>
    <key>ProgramArguments</key>
    <array>
    	<string>/usr/bin/open</string>
        <string>-a</string>
	<string>/Applications/Firefox.app</string>
	<string>--args</string>
	<string>--foreground</string>
	<string>--profile</string>
	<string>/Users/Shared/corsica-profile/</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

cat > /Library/LaunchDaemons/reset-firefox-session.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>reset-firefox-session</string>
    <key>ProgramArguments</key>
    <array>
        <string>bash</string>
        <string>-c</string>
        <string>rm -rf /Users/Shared/corsica-profile/sessionstore*;
        rm -rf /Users/corsica/Library/Preferences/ByHost/com.apple.loginwindow.*</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF