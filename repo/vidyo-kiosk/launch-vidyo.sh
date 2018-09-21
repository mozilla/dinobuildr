#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script creates a LaunchAgent and LaunchDaemon. The LaunchAgent 
# launches vidyodesktop under the vidyouser user at login. 

cat > /Users/Shared/move-launch-vidyodesktop.sh <<- "EOF"
#!/bin/bash

if [ ! -d /Users/vidyouser/Library/LaunchAgents ]; then
    mkdir /Users/vidyouser/Library/LaunchAgents
    chown vidyouser /Users/vidyouser/Library/LaunchAgents
fi
 
mv /Users/Shared/launch-vidyodesktop.plist /Users/vidyouser/Library/LaunchAgents/launch-vidyodesktop.plist
chown vidyouser /Users/vidyouser/Library/LaunchAgents/launch-vidyodesktop.plist

chown -R vidyouser:staff /Applications/VidyoDesktop.app/

rm -rf /Library/LaunchDaemons/move-launch-vidyodesktop.plist

rm -rf "$0"
EOF

chmod +x /Users/Shared/move-launch-vidyodesktop.sh

cat > /Library/LaunchDaemons/move-launch-vidyodesktop.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>move-launch-vidyodesktop</string>
    <key>Program</key>
    <string>/Users/Shared/move-launch-vidyodesktop.sh</string>
    <key>WatchPaths</key>
    <array>
        <string>/Users/vidyouser/Library</string>
    </array>
</dict>
</plist>
EOF

cat > /Users/Shared/launch-vidyodesktop.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>launch-vidyodesktop</string>
    <key>ProgramArguments</key>
    <array>
    	<string>/usr/bin/open</string>
        <string>-a</string>
	<string>/Applications/VidyoDesktop.app</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
