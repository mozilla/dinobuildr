#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script verifies that sharing analytics with Apple and app developers is disabled.

AUTO_SUBMIT=$(defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit)
THIRD_PARTY_DATA_SUBMIT=$(defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist ThirdPartyDataSubmit)

if [[ ${AUTO_SUBMIT} -eq 1 ]]; then
	defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -boolean false

	if [[ ${THIRD_PARTY_DATA_SUBMIT} -eq 1 ]]; then
		defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist ThirdPartyDataSubmit -boolean false
	fi
	chmod a+r /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist
	chown root:admin /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist
fi