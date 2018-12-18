#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Credit for most of this code goes to barnesaw from the JAMF Nation forums.
# This script disables the screensaver under the corsica user account.

MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')

for USER_TEMPLATE in "/System/Library/User Template"/*; do
	/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.screensaver."${MAC_UUID}" "idleTime" -int 0
done
