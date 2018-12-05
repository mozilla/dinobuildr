#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Disable the guest account via plist

defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool FALSE

exit 0
