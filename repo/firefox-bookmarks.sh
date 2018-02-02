#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script imports bookmarks into Firefox using the distribution.ini file.

user=`python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");'`

mkdir /Applications/Firefox.app/Contents/Resources/distribution
chown ${user} /Applications/Firefox.app/Contents/Resources/distribution

cat > /Applications/Firefox.app/Contents/Resources/distribution/distribution.ini <<- "EOF"
[Global]
id=dinobuildr
version=1.0
about=The default bookmarks were set by ServiceDesk using dinobuildr.

[BookmarksMenu]
item.1.title=Mozilla email
item.1.link=https://sso.mozilla.com/gmail
item.2.title=Vidyo Conferencing
item.2.link=https://v.mozilla.com
item.3.title=The Hub
item.3.link=https://thehub.mozilla.com/sp
item.4.title=Bugzilla
item.4.link=https://bugzilla.mozilla.org
item.5.title=Mozilla Phonebook
item.5.link=https://phonebook.mozilla.org
item.6.title=New Hire Info
item.6.link=https://mana.mozilla.org/wiki/display/SD/New+Hire+IT+Information
item.7.title=IRCCloud
item.7.link=https://irccloud.mozilla.com
item.8.title=Slack
item.8.link=https://mozilla.slack.com
item.9.title=Air Mozilla
item.9.link=https://air.mozilla.org
item.10.title=Mozilla Account Portal
item.10.link=https://login.mozilla.com
item.11.title=Workday
item.11.link=https://sso.mozilla.com/workday
item.12.title=Expensify
item.12.link=https://www.expensify.com/signin
item.13.title=Mozilla PTO
item.13.link=https://pto.mozilla.org
EOF

chown ${user} /Applications/Firefox.app/Contents/Resources/distribution/distribution.ini