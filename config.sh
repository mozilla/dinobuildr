#!/bin/bash

# This script will pull down all the files from a repository and begin to process them in the following order:
# 1. Any DMGs with .App installer bundles in them will be mounted and the .App will be copied to /Applications
# 2. Any PKG file will be installed against /
# 3. Any shell scripts will be executed

# Set the local repo so we can create it if doesn't exist, and then export this variable so that other shell scripts that this script calls can know their woring directory.

LOCAL_REPO="/usr/local/mozbuild/"
export LOCAL_REPO

sudo mkdir -p $LOCAL_REPO

# Set the remote repo where we will grab that packages. Remote repo needs an index or else curl can't dig through it. 
REMOTE_REPO="http://192.168.139.180/mozbuild/packages/"

# curl will silently cruise the remote repo index and grab the filenames from the responses by passing the return values off to grep and sed. 
# Then we re-curl the file list that that we grabbed before and make all the files we grab executable (there is almost certainly a cleaner way to do that bit). 
for FILE in $(curl -s ${REMOTE_REPO} |
		grep href |
		sed 's/.*href="//' |
		sed 's/".*//' |
		grep '^[a-zA-Z].*'); do
	sudo curl -o "${LOCAL_REPO}$FILE" "${REMOTE_REPO}$FILE"
	sudo chmod +x "${LOCAL_REPO}$FILE"
done


# Function: dmgInstall - The DMG installer function mounts a DMG, copies any .app bundle out to /Applications, then unmounts the DMG when it's done
function dmgInstall {
	VOLUME=`hdiutil attach $1 | grep Volumes | awk '{print $3}'`
	echo "Mounted ${VOLUME}, proceeding to copy installer"
	cp -rf $VOLUME/*.app /Applications
	echo ".App copied to /Applications"
	hdiutil detach $VOLUME
	echo "${VOLUME} unmounted"
}

# Function: pkgInstall - The PKG installer function simply calls installer and install the package against the root volume of the machine 

function pkgInstall {
	sudo installer -pkg $1 -target /
}

# Export the the above functions so that find can call them
export -f dmgInstall
export -f pkgInstall

# Each find command divides the repo up by .dmg, .pkg and .sh files and execute the appropriate functions (or just the shells scripts direct). 
find ${LOCAL_REPO}*.dmg -exec bash -c 'dmgInstall "$0"' {} \;
find ${LOCAL_REPO}*.pkg -exec bash -c 'pkgInstall "$0"' {} \;
find ${LOCAL_REPO}*.sh -exec {} \;
