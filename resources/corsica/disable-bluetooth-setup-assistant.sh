#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script disables Bluetooth Setup Assistant at startup if no
# keyboard, mouse, or trackpad is detected.

defaults write /Library/Preferences/com.apple.Bluetooth.plist BluetoothAutoSeekKeyboard 0

defaults write /Library/Preferences/com.apple.Bluetooth.plist BluetoothAutoSeekPointingDevice 0