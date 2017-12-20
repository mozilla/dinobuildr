#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script sets the $REBOOTWHENDONE environment variable to tell Dinobuildr
# that we want to reboot at the end of the build.

export REBOOTWHENDONE=true
