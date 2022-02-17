#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script imports bookmarks into Firefox using the Firefox policy engine.

user=$(python -c '
from SystemConfiguration import SCDynamicStoreCopyConsoleUser;
import sys;
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0];
username = [username,""][username in [u"loginwindow", None, u""]];
sys.stdout.write(username + "\n");')

mkdir /Applications/Firefox.app/Contents/Resources/distribution
chown "${user}" /Applications/Firefox.app/Contents/Resources/distribution

cat > /Applications/Firefox.app/Contents/Resources/distribution/policies.json <<- "EOF"
{
  "policies": {
    "DisplayBookmarksToolbar": true,
    "NoDefaultBookmarks": true,
    "Bookmarks": [
      {
        "Title": "Mozilla SSO",
        "URL": "https://sso.mozilla.com",
        "Placement": "toolbar"
      }
    ]
  }
}
EOF

chown "${user}" /Applications/Firefox.app/Contents/Resources/distribution/policies.json
