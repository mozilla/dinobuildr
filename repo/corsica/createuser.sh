#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this is a very crude way of generating a user. it's basically the same method
# that Greg Neagle uses in pycreateuserpkg
# (https://github.com/gregneagle/pycreateuserpkg), since we just used that to
# generate a user, pasted the plist in this script and copy of the kcpassword
# file in future times, we'd need to let dinobuildr execute python directly and
# we'll actually write the kcpassword file dynamically

userplist=corsica.plist
passwordfile=kcpassword
username=corsica

echo "Creating a user: $username" 

# we just include the user plist inside this script so we don't have to have a separate file floating around.

mkdir -p "/var/db/dslocal/nodes/Default/users/"

(
set -e
cat > "/var/db/dslocal/nodes/Default/users/$userplist" <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ShadowHashData</key>
	<array>
		<data>
		YnBsaXN0MDDRAQJfEBRTQUxURUQtU0hBNTEyLVBCS0RGMtMDBAUGBwhUc2Fs
		dFdlbnRyb3B5Wml0ZXJhdGlvbnNPECC6f48Omu3sK3J1BAuhrgpA/3m+TWF+
		4/mjaKtfW452Y08QgAYnGHZL2qmGrgaChiRVWkhgdCQKvoteRRsaaquU/jHZ
		0nxvStTy9Xs8cgOVKzoDoaKhoHk10/ZOCwERA/+t5OOtjbzOg4790y3yUn0i
		U/uzLzK93KMnhpamxFf6FnEIM77yRoQf7myLatg0242Ik3vsyl5fgmTAbq4I
		QAq77Dx5EX2ICAsiKS42QWTnAAAAAAAAAQEAAAAAAAAACQAAAAAAAAAAAAAA
		AAAAAOo=
		</data>
	</array>
	<key>_writers_UserCertificate</key>
	<array>
		<string>corsica</string>
	</array>
	<key>_writers_hint</key>
	<array>
		<string>corsica</string>
	</array>
	<key>_writers_jpegphoto</key>
	<array>
		<string>corsica</string>
	</array>
	<key>_writers_passwd</key>
	<array>
		<string>corsica</string>
	</array>
	<key>_writers_picture</key>
	<array>
		<string>corsica</string>
	</array>
	<key>_writers_realname</key>
	<array>
		<string>corsica</string>
	</array>
	<key>authentication_authority</key>
	<array>
		<string>;ShadowHash;HASHLIST:&lt;SALTED-SHA512-PBKDF2&gt;</string>
	</array>
	<key>generateduid</key>
	<array>
		<string>8953B7B2-0065-4A9A-BC2A-DE9D9ADE1B7B</string>
	</array>
	<key>gid</key>
	<array>
		<string>20</string>
	</array>
	<key>home</key>
	<array>
		<string>/Users/corsica</string>
	</array>
	<key>name</key>
	<array>
		<string>corsica</string>
	</array>
	<key>passwd</key>
	<array>
		<string>********</string>
	</array>
	<key>realname</key>
	<array>
		<string>corsica</string>
	</array>
	<key>shell</key>
	<array>
		<string>/bin/bash</string>
	</array>
	<key>uid</key>
	<array>
		<string>601</string>
	</array>
</dict>
</plist>
EOF
set +e
)

# here we copy the kcpassword file and set a bunch of perms.
# the password is not clever or secret and would have been blank if we could
# have made that work.  some of these ownership / permsisions changes are not
# necessary but better safe than sorry.

cp "${DINOPATH}/$passwordfile" "/etc/$passwordfile"
/bin/chmod 700 "/var/db/dslocal/nodes/Default/users/"
/bin/chmod 600 "/var/db/dslocal/nodes/Default/users/$userplist"
/usr/sbin/chown -R root:wheel "/var/db/dslocal/nodes/Default/users/"
/bin/chmod 600 "/etc/$passwordfile"
/usr/sbin/chown -R root:wheel "/etc/$passwordfile"
/usr/bin/defaults write "/Library/Preferences/com.apple.loginwindow" autoLoginUser $username
