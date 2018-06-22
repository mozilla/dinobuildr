#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# code provided by barnesaw in the JAMF Nation forums:
# https://www.jamf.com/jamf-nation/discussions/19769/disable-notifcations-via-script-equivalent-to-option-clicking-notifications

MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')

# Setup DND on NotificationCenter
 for USER_TEMPLATE in "/System/Library/User Template"/*
  do
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "dndEnd" -float 1379
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "doNotDisturb" -bool FALSE
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "dndStart" -float 1380
  done
