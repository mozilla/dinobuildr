#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script installs a configuration profile to suppress the Touch ID
# Setup Assistant screen

cat > /Users/Shared/SkipTouchIDSetup.mobileconfig <<- "EOF"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>PayloadIdentifier</key>
		<string>8631AADD-FAEF-4712-A771-D2B7344129FE</string>
		<key>PayloadRemovalDisallowed</key>
		<false/>
		<key>PayloadScope</key>
		<string>System</string>
		<key>PayloadType</key>
		<string>Configuration</string>
		<key>PayloadUUID</key>
		<string>8631AADD-FAEF-4712-A771-D2B7344129FE</string>
		<key>PayloadOrganization</key>
		<string>Mozilla Corporation</string>
		<key>PayloadVersion</key>
		<integer>1</integer>
		<key>PayloadDisplayName</key>
		<string>Skip Touch ID Setup</string>
		<key>PayloadContent</key>
		<array>
			<dict>
				<key>PayloadType</key>
				<string>com.apple.SetupAssistant.managed</string>
				<key>PayloadVersion</key>
				<integer>1</integer>
				<key>PayloadIdentifier</key>
				<string>A0A6183A-0604-44CB-8FC6-631D2AF232B1</string>
				<key>PayloadEnabled</key>
				<true/>
				<key>PayloadUUID</key>
				<string>A0A6183A-0604-44CB-8FC6-631D2AF232B1</string>
				<key>PayloadDisplayName</key>
				<string>Login Window</string>
				<key>SkipTouchIDSetup</key>
				<true/>
			</dict>
		</array>
	</dict>
</plist>
EOF

/usr/bin/profiles -I -F /Users/Shared/SkipTouchIDSetup.mobileconfig