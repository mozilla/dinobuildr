#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script closes CrashPlan, which automatically launches after
# installation. While there are methods to customize the CrashPlan installer
# and tell it not to auto-launch, those customizations involve modifying the
# installer and we're trying to avoid doing that. 

echo "Waiting for Crashplan to launch and then quitting it..."
osascript -e 'quit app "CrashPlan"' 
