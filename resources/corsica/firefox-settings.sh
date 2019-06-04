#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script disables the default browser check and sets Corsica as
# the homepage using the Firefox policy engine. The homepage policy
# requires Firefox ESR.

mkdir /Applications/Firefox.app/Contents/Resources/distribution

(
set -e
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
set +e
)

mkdir /Users/Shared/corsica-profile

# Set preferences
# * full-screen-api.allow-trusted-requests-only = false - Allow Corsica to go full screen without interaction
# * media.autoplay.default = 0 - Allow video autoplay, even with sound
(
set -e
cat > /Users/Shared/corsica-profile/prefs.js <<- "EOF"
user_pref("full-screen-api.allow-trusted-requests-only", false);
user_pref("media.autoplay.default", 0);
EOF
set +e
)

/bin/chmod -R 777 /Users/Shared/corsica-profile/
