#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script installs a configuration profile to suppress the iCloud
# Setup Assistant screen

cat > /Users/Shared/SkipiCloudSetup.mobileconfig <<- "EOF"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>PayloadIdentifier</key>
		<string>com.mozilla.cse.C933F5EA-CAD4-4268-BBC0-ADB55465926B</string>
		<key>PayloadRemovalDisallowed</key>
		<false/>
		<key>PayloadScope</key>
		<string>System</string>
		<key>PayloadType</key>
		<string>Configuration</string>
		<key>PayloadUUID</key>
		<string>C933F5EA-CAD4-4268-BBC0-ADB55465926B</string>
		<key>PayloadOrganization</key>
		<string>Mozilla Corporation</string>
		<key>PayloadVersion</key>
		<integer>1</integer>
		<key>PayloadDescription</key>
		<string>Skips the iCloud Setup pop-up window</string>
		<key>PayloadDisplayName</key>
		<string>Skip iCloud Setup</string>
		<key>PayloadContent</key>
		<array>
			<dict>
				<key>PayloadType</key>
				<string>com.apple.SetupAssistant.managed</string>
				<key>PayloadVersion</key>
				<integer>1</integer>
				<key>PayloadIdentifier</key>
				<string>com.mozilla.cse.7BC6F6C1-1263-44E0-AF88-B7176383F61A</string>
				<key>PayloadEnabled</key>
				<true/>
				<key>PayloadUUID</key>
				<string>7BC6F6C1-1263-44E0-AF88-B7176383F61A</string>
				<key>PayloadDisplayName</key>
				<string>Login Window</string>
				<key>SkipCloudSetup</key>
				<true/>
			</dict>
		</array>
	</dict>
</plist>
EOF

/usr/bin/profiles -I -F /Users/Shared/SkipiCloudSetup.mobileconfig