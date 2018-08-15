#!/bin/bash

cat > /usr/local/auto-update-routine.sh <<- "EOF"
	#!/bin/bash
	if [ "$(curl https://raw.githubusercontent.com/luciusbono/informant/master/informant.txt)" = "greenlight" ]; then
	    softwareupdate -ia
	fi

	shutdown -r now
	
	if [ "$1" = "canary" ]; then
		cat > /Library/LaunchDaemons/update-ff-macos.plist <<- "EOF2"
			<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
			<plist version="1.0">
			<dict>
			    <key>Label</key>
			    <string>update-firefox-macos</string>
			    <key>Program</key>
			    <string>/usr/local/auto-update-routine.sh</string>
			    <key>StartCalendarInterval</key>
			    <dict>
			        <key>Hour</key>
			        <integer>3</integer>
			        <key>Minute</key>
			        <integer>00</integer>
			    </dict>
			</dict>
			</plist>
			EOF2
	fi
EOF

chmod +x /usr/local/auto-update-routine.sh

cat > /Library/LaunchDaemons/update-ff-macos.plist <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>update-firefox-macos</string>
    <key>Program</key>
    <string>/usr/local/auto-update-routine.sh</string>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Day</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>3</integer>
            <key>Minute</key>
            <integer>00</integer>
        </dict>
        <dict>
            <key>Day</key>
            <integer>15</integer>
            <key>Hour</key>
            <integer>3</integer>
            <key>Minute</key>
            <integer>00</integer>
        </dict>
    </array>
</dict>
</plist>
EOF

launchctl unload /Library/LaunchDaemons/update-ff-macos.plist
launchctl load /Library/LaunchDaemons/update-ff-macos.plist
