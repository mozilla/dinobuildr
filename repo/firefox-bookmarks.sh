#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script imports bookmarks into Firefox using the Firefox policy engine.

user=`python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");'`

mkdir /Applications/Firefox.app/Contents/Resources/distribution
chown ${user} /Applications/Firefox.app/Contents/Resources/distribution

cat > /Applications/Firefox.app/Contents/Resources/distribution/policies.json <<- "EOF"
{
  "policies": {
    "DisplayBookmarksToolbar": true,
    "NoDefaultBookmarks": true,
    "Bookmarks": [
      {
        "Title": "Mozilla email",
        "URL": "https://sso.mozilla.com/gmail",
        "Placement": "toolbar"
      },
      {
        "Title": "Vidyo Conferencing",
        "URL": "https://v.mozilla.com",
        "Placement": "toolbar"
      },
      {
        "Title": "The Hub",
        "URL": "https://thehub.mozilla.com/sp",
        "Placement": "toolbar"
      },
      {
        "Title": "Bugzilla",
        "URL": "https://bugzilla.mozilla.org",
        "Placement": "toolbar"
      },
      {
        "Title": "Mozilla Phonebook",
        "URL": "https://phonebook.mozilla.org",
        "Placement": "toolbar"
      },
      {
        "Title": "New Hire Info",
        "URL": "https://mana.mozilla.org/wiki/display/SD/New+Hire+IT+Information",
        "Placement": "toolbar"
      },
      {
        "Title": "IRCCloud",
        "URL": "https://irccloud.mozilla.com",
        "Placement": "toolbar"
      },
      {
        "Title": "Slack",
        "URL": "https://mozilla.slack.com",
        "Placement": "toolbar"
      },
      {
        "Title": "Air Mozilla",
        "URL": "https://air.mozilla.org",
        "Placement": "toolbar"
      },
      {
        "Title": "Mozilla Account Portal",
        "URL": "https://login.mozilla.com",
        "Placement": "toolbar"
      },
      {
        "Title": "Workday",
        "URL": "https://sso.mozilla.com/workday",
        "Placement": "toolbar"
      },
      {
        "Title": "Expensify",
        "URL": "https://sso.mozilla.com/expensify",
        "Placement": "toolbar"
      },
      {
        "Title": "Mozilla PTO",
        "URL": "https://pto.mozilla.org",
        "Placement": "toolbar"
      }
    ]
  }
}
EOF

chown ${user} /Applications/Firefox.app/Contents/Resources/distribution/policies.json