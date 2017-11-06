#!/bin/bash

hash="c49ba68db90f7ac3a50a490e597078df6de6a8feba16c24ccced7b34d84f705e"
dockutil=$(curl -fsSL https://raw.githubusercontent.com/kcrawford/dockutil/b7fcec8aae863cd83cb27c2cf8bd3e739ece0795/scripts/dockutil)

if [ $(echo "$dockutil" | shasum -a 256 | awk {'print $1'}) == $hash ]; then
	echo "Executing dockutil - hash matches expected value."	
	python -c "$dockutil" --remove all --no-restart
	python -c "$dockutil" --add "/Applications/Launchpad.app" --position beginning --no-restart
	python -c "$dockutil" --add "/Applications/Firefox.app" --after Launchpad --no-restart
	python -c "$dockutil" --add "/Applications/VidyoDesktop.app" --after Firefox --no-restart
	python -c "$dockutil" --add "/Applications/Crashplan.app" --after VidyoDesktop --no-restart
	python -c "$dockutil" --add "/Applications/System Preferences.app" --position end
else 
	echo "Dockutil hash does not match intended value. Aborting."
	exit 1
fi
