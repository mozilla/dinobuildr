#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script creates a LaunchAgent and LaunchDaemon. The LaunchAgent 
# launches vidyodesktop under the vidyouser user at login. 

WALLPAPER_FILENAME=wallpaper.jpg
cp "${DINOPATH}/$WALLPAPER_FILENAME" "/Users/Shared/$WALLPAPER_FILENAME"


cat > /Users/Shared/move-set-desktopwallpaper.sh <<- "EOF"
#!/bin/bash

if [ ! -d /Users/vidyouser/Library/LaunchAgents ]; then
    mkdir /Users/vidyouser/Library/LaunchAgents
    chown vidyouser /Users/vidyouser/Library/LaunchAgents
fi
 
mv /Users/Shared/set-desktopwallpaper.plist /Users/vidyouser/Library/LaunchAgents/set-desktopwallpaper.plist
chown vidyouser /Users/vidyouser/Library/LaunchAgents/set-desktopwallpaper.plist

chown -R vidyouser:staff /Applications/VidyoDesktop.app/

rm -rf /Library/LaunchDaemons/move-set-desktopwallpaper.plist

rm -rf "$0"
EOF

chmod +x /Users/Shared/move-set-desktopwallpaper.sh

cat > /Library/LaunchDaemons/move-set-desktopwallpaper.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>move-set-desktopwallpaper</string>
    <key>Program</key>
    <string>/Users/Shared/move-set-desktopwallpaper.sh</string>
    <key>WatchPaths</key>
    <array>
        <string>/Users/vidyouser/Library</string>
    </array>
</dict>
</plist>
EOF

cat > /Users/Shared/set-desktopwallpaper.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>set-desktopwallpaper</string>
    <key>Program</key>
    <array>
    	<string>/Users/Shared/set-desktopwallpaper.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

cat > /Users/Shared/set-desktopwallpaper.sh <<- "EOF"
#!/bin/bash

WALLPAPER_FILENAME=wallpaper.jpg

echo "We're setting the dang wallpaper now."
$(which osascript) -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/'"$WALLPAPER_FILENAME"'"'
EOF
