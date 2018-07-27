#!/bin/bash

cat > /Library/LaunchDaemons/update-ff-macos.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>update-firefox-macos</string>
    <key>ProgramArguments</key>
    <array>
        <string>bash</string>
        <string>-c</string>
        <string>softwareupdate -ia;
        osascript -e 'tell app "System Events" to restart'</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>00</integer>
    </dict>
</dict>
</plist>
EOF

launchctl load /Library/LaunchDaemons/update-ff-macos.plist
