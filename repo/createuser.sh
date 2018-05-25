#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

userplist=corsica.plist
passwordfile=kcpassword
username=corsica

echo "Creating a user: $username" 

mkdir -p "/var/db/dslocal/nodes/Default/users/"
cp "${DINOPATH}/$userplist" "/var/db/dslocal/nodes/Default/users/$userplist"
cp "${DINOPATH}/$passwordfile" "/etc/$passwordfile"
/bin/chmod 700 "/var/db/dslocal/nodes/Default/users/"
/bin/chmod 600 "/var/db/dslocal/nodes/Default/users/$userplist"
/usr/sbin/chown -R root:wheel "/var/db/dslocal/nodes/Default/users/"
/bin/chmod 600 "/etc/$passwordfile"
/usr/sbin/chown -R root:wheel "/etc/$passwordfile"
/usr/bin/defaults write "/Library/Preferences/com.apple.loginwindow" autoLoginUser "$username"
/bin/chmod 644 "/Library/Preferences/com.apple.loginwindow.plist"
/usr/bin/killall DirectoryService 2>/dev/null || /usr/bin/killall opendirectoryd 2>/dev/null
