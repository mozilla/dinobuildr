#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This script installs a configuration profile to suppress the Data
# and Privacy Setup Assistant screen

cat > /Users/Shared/SkipDataAndPrivacy.mobileconfig <<- "EOF"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>PayloadIdentifier</key>
		<string>2F1B7BDB-C2EC-4D07-8EB5-F83D3F1E703F</string>
		<key>PayloadRemovalDisallowed</key>
		<false/>
		<key>PayloadScope</key>
		<string>System</string>
		<key>PayloadType</key>
		<string>Configuration</string>
		<key>PayloadUUID</key>
		<string>2F1B7BDB-C2EC-4D07-8EB5-F83D3F1E703F</string>
		<key>PayloadOrganization</key>
		<string>Mozilla Corporation</string>
		<key>PayloadVersion</key>
		<integer>1</integer>
		<key>PayloadDescription</key>
		<string>Skips the Apple Privacy pop-up window</string>
		<key>PayloadDisplayName</key>
		<string>Skip Apple Privacy Message</string>
		<key>PayloadContent</key>
		<array>
			<dict>
				<key>PayloadType</key>
				<string>com.apple.SetupAssistant.managed</string>
				<key>PayloadVersion</key>
				<integer>1</integer>
				<key>PayloadIdentifier</key>
				<string>4C3AFBD4-211F-46A6-81E3-168C88E443B4</string>
				<key>PayloadEnabled</key>
				<true/>
				<key>PayloadUUID</key>
				<string>4C3AFBD4-211F-46A6-81E3-168C88E443B4</string>
				<key>PayloadDisplayName</key>
				<string>Login Window</string>
				<key>SkipPrivacySetup</key>
				<true/>
			</dict>
		</array>
	</dict>
</plist>
EOF

/usr/bin/profiles -I -F /Users/Shared/SkipDataAndPrivacy.mobileconfig