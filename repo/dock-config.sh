#!/bin/bash

dockutil="$(curl -fsSL https://raw.githubusercontent.com/kcrawford/dockutil/b7fcec8aae863cd83cb27c2cf8bd3e739ece0795/scripts/dockutil)"

python -c "$dockutil" --remove all --no-restart
python -c "$dockutil" --add "/Applications/Launchpad.app" --position beginning --no-restart
python -c "$dockutil" --add "/Applications/Firefox.app" --after Launchpad --no-restart
python -c "$dockutil" --add "/Applications/VidyoDesktop.app" --after Firefox --no-restart
python -c "$dockutil" --add "/Applications/Crashplan.app" --after VidyoDesktop --no-restart
python -c "$dockutil" --add "/Applications/System Preferences.app" --position end
