#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script disables the default browser check and sets Corsica as
# the homepage using the Firefox policy engine. The homepage policy
# requires Firefox ESR.

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
    "OverrideFirstRunPage": "",
    "OverridePostUpdatePage": "",
    "DontCheckDefaultBrowser": true,
    "Homepage": {
      "URL": "https://corsica.mozilla.io/"
    }
  }
}
EOF

chown ${user} /Applications/Firefox.app/Contents/Resources/distribution/policies.json