#!/bin/bash

MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')

# Setup DND on NotificationCenter
 for USER_TEMPLATE in "/System/Library/User Template"/*
  do
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "dndEnd" -float 1379
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "doNotDisturb" -bool FALSE
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.notificationcenterui.$MAC_UUID "dndStart" -float 1380
  done
