#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script enables the firewall.

defaults write /Library/Preferences/com.apple.alf globalstate -int 1 || {
    echo "Failed to enable the firewall."
    exit 200
}
