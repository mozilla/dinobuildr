#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

loggedInUser=`python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");'`

if [ ! -d /usr/local/bin ]; then
    mkdir /usr/local/bin
    chown ${loggedInUser} /usr/local/bin
fi

cat > /usr/local/bin/fv-keyprompt.sh <<-"EOF"
	#!/bin/bash

	export loggedInUser=`python -c '
	from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
	import sys;
	username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
	username = [username,""][username in [u"loginwindow", None, u""]];
	sys.stdout.write(username + "\n");'`
	
	while [ ! -O /Users/${loggedInUser}/Library/fvkey.plist ]; do
	    sleep 2
	done

	recovery_key=$(/usr/libexec/PlistBuddy -c "Print :RecoveryKey" /Users/"${loggedInUser}"/Library/fvkey.plist)
	
	osascript <<-EOF2
		display dialog "Filevault has been activated on this machine.\n\nYour Filevault recovery key is:\n\n${recovery_key}\n\nPlease escrow this key in WDE by browsing to:\n https://wde.allizom.org" buttons {"Continue"} default button 1 with title "Filevault Recovery Key"
			return
EOF2

	# rm /Users/${loggedInUser}/Library/fvkey.plist
	# rm /usr/local/bin/fv-keyprompt.sh 
	# launchctl unload /Users/${loggedInUser}/Library/LaunchAgents/fv-keyprompt.plist
	# rm /Users/${loggedInUser}/Library/LaunchAgents/fv-keyprompt.plist
EOF

if [ ! -d /Users/${loggedInUser}/Library/LaunchAgents ]; then
    mkdir /Users/${loggedInUser}/Library/LaunchAgents
    chown ${loggedInUser} /Users/${loggedInUser}/Library/LaunchAgents
fi

cat > /usr/local/bin/chownfvkey.sh<<-"EOF"
	#!/bin/bash

	export loggedInUser=`python -c '
	from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
	import sys;
	username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
	username = [username,""][username in [u"loginwindow", None, u""]];
	sys.stdout.write(username + "\n");'`
	
	while [ ! -f /Users/${loggedInUser}/Library/fvkey.plist ]; do
	    sleep 2
	done

	chown $loggedInUser /Users/${loggedInUser}/Library/fvkey.plist

	# rm /usr/local/bin/chownfvkey.sh
	# launchctl unload /Library/LaunchDaemons/com.mozilla-it.chownfvkey.plist
	# rm //Library/LaunchDaemons/com.mozilla-it.chownfvkey.plist
EOF

cat > /Library/LaunchDaemons/com.mozilla-it.chownfvkey.plist<<-"EOF"
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>Label</key>
	    <string>com.mozilla-it.chownfvkey</string>
	    <key>ProgramArguments</key>
	    <array>
	        <string>/bin/bash</string>
	        <string>/usr/local/bin/chownfvkey.sh</string>
	    </array>
	    <key>RunAtLoad</key>
	    <true/>
	</dict>
	</plist>
EOF

cat > /Users/${loggedInUser}/Library/LaunchAgents/com.mozilla-it.fv-keyprompt.plist <<-"EOF"
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>Label</key>
	    <string>com.mozilla-it.fv-keyprompt</string>
	    <key>ProgramArguments</key>
	    <array>
	        <string>/bin/bash</string>
	        <string>/usr/local/bin/fv-keyprompt.sh</string>
	    </array>
	    <key>RunAtLoad</key>
	    <true/>
	</dict>
	</plist>
EOF

chmod +x /usr/local/bin/fv-keyprompt.sh
chmod +x /usr/local/bin/chownfvkey.sh
