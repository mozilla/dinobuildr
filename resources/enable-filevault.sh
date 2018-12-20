#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Determine logged in user through the "usual apple way"

loggedInUser=$(python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");')

# Enable FileVault 2 using the defer option, this will attempt to turn on
# FileVault 2 at the next login/logout and prompt the user for the account
# password that executed this command, then drops the recovery key in a plist
# owned by roo at the location we specify. 
#
# We use this method because all other methods of programmatically enabling FV2
# require the user password to be passed to fdesetup and we don't want to
# encourage people to type their account passwords into random dialog boxes. 

echo "Enabling FileVault deffered enrollment."
fdesetup enable -defer /Users/"${loggedInUser}"/Library/fvkey.plist -forceatlogin 0 -dontaskatlogout

# Generate a LaunchDaemon via heredoc that will execute the chownfvkey.sh that
# we will write later in this script. 

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

# Create /usr/local/bin if it doesn't exist so we can throw scripts in it.

if [ ! -d /usr/local/bin ]; then
    mkdir /usr/local/bin
    chown "$loggedInUser" /usr/local/bin
fi

# Generate a script that will take ownership of a file called fvkey.plist. This
# file is normally owned by root, and is an artifact of the FileVault 2 deffered
# enrollment procedure, which we use because we don't want to capture account
# passwords via any "non official" method (even though the way Apple does it
# looks a little sketchy to me still, personally). 

# First we wait until the fvkey.plist file exists, which it should already.
# Then we take ownership of the file as the user and clean up the script
# artifacts and the LaunchDaemon.

cat > /usr/local/bin/chownfvkey.sh <<-EOF
	#!/bin/bash

	while [ ! -f /Users/"${loggedInUser}"/Library/fvkey.plist ]; do
	    sleep 2
	done

	chown "$loggedInUser" /Users/"${loggedInUser}"/Library/fvkey.plist

	rm /usr/local/bin/chownfvkey.sh
	rm /Library/LaunchDaemons/com.mozilla-it.chownfvkey.plist
    launchctl remove com.mozilla-it.chownfvkey
EOF

# If the user's LaunchAgents directory doesn't exist, create it so we can drop a
# LaunchAgent. 

if [ ! -d /Users/"${loggedInUser}"/Library/LaunchAgents ]; then
    mkdir /Users/"${loggedInUser}"/Library/LaunchAgents
    chown "$loggedInUser" /Users/"${loggedInUser}"/Library/LaunchAgents
fi

# Generate a LaunchAgent via heredoc that will execute the fv-keyprompt.sh
# script that we will write later on in this script. 

cat > /Users/"${loggedInUser}"/Library/LaunchAgents/com.mozilla-it.fv-keyprompt.plist <<-"EOF"
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

# Generate the FileVault 2 prompt script via a heredoc that the LaunchAgent will
# fire off.

# First, determine the logged in user through the usual "apple way"
# Then, wait until we can act on the fvkey.plist file. The file is normally
# owned by root, but a LaunchDaemon we create will fix that. 
# Use PlistBuddy to read the recovery key to the file, then pass that key to a
# simple Applescript prompt via yet another heredoc.
# When finished, clean up the script artifacts, the key file and the LaunchAgent

# Note: I'm not good enough at bash to know the best way to just pass the user
# in to this heredoc from the main script, because we're using a command
# subsitution and if I don't specify a literal interpretation of the heredoc,
# the script attempts to run the command substitution. This is something that
# should probably be fixed later by either avo iding the subsitution or learning
# more about heredocs. 

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
		display dialog "FileVault has been activated on this machine.\n\nYour FileVault recovery key is:\n\n${recovery_key}\n\nPlease escrow this key in WDE by browsing to:\nhttps://wde.mozilla.org/" buttons {"Continue"} default button 1 with title "FileVault Recovery Key"
			return
	EOF2

	rm /Users/${loggedInUser}/Library/fvkey.plist
	rm /usr/local/bin/fv-keyprompt.sh 
	rm /Users/${loggedInUser}/Library/LaunchAgents/com.mozilla-it.fv-keyprompt.plist
	launchctl remove com.mozilla-it.fv-keyprompt
EOF

# Make the scripts we drop with the above heredocs executable for good measure. 

chmod +x /usr/local/bin/fv-keyprompt.sh
chmod +x /usr/local/bin/chownfvkey.sh
