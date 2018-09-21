#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Disable system sleep
pmset sleep 0

# Set display sleep to one hour
pmset displaysleep 60

# Enable automatic restart on power loss
pmset autorestart 1
