#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# remove pyobjc-framework-SystemConfigruation package
# remove Command line Tools, the user can reinstall it (or xcode) if they want.
# this is to make sure that we don't leave anything behind with dinobuildr

pip3 uninstall -y pyobjc-framework-SystemConfiguration
pip3 uninstall -y pyobjc-core
pip3 uninstall -y pyobjc-framework-Cocoa
rm -rf /Library/Developer/CommandLineTools