#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Enable automatic updates for the App Store.

# Enable automatic updates for apps from the App Store
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE

# Enable automatic macOS updates
defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE
