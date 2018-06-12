#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script installs a configuration profile to suppress the Siri
# Setup Assistant screen

cat > /Users/Shared/SkipSiriSetup.mobileconfig <<- "EOF"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>PayloadIdentifier</key>
		<string>1CED00D4-CDB0-4545-9C4D-903E3247351C</string>
		<key>PayloadRemovalDisallowed</key>
		<false/>
		<key>PayloadScope</key>
		<string>System</string>
		<key>PayloadType</key>
		<string>Configuration</string>
		<key>PayloadUUID</key>
		<string>1CED00D4-CDB0-4545-9C4D-903E3247351C</string>
		<key>PayloadOrganization</key>
		<string>Company Name</string>
		<key>PayloadVersion</key>
		<integer>1</integer>
		<key>PayloadDescription</key>
		<string>Skips the Siri Setup pop-up window</string>
		<key>PayloadDisplayName</key>
		<string>Skip Siri Setup</string>
		<key>PayloadContent</key>
		<array>
			<dict>
				<key>PayloadType</key>
				<string>com.apple.SetupAssistant.managed</string>
				<key>PayloadVersion</key>
				<integer>1</integer>
				<key>PayloadIdentifier</key>
				<string>8F15320D-31BC-4CF7-9965-7465AC50B39B</string>
				<key>PayloadEnabled</key>
				<true/>
				<key>PayloadUUID</key>
				<string>8F15320D-31BC-4CF7-9965-7465AC50B39B</string>
				<key>PayloadDisplayName</key>
				<string>Login Window</string>
				<key>SkipSiriSetup</key>
				<true/>
			</dict>
		</array>
	</dict>
</plist>
EOF

/usr/bin/profiles -I -F /Users/Shared/SkipSiriSetup.mobileconfig