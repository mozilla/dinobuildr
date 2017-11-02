#!/bin/bash

dockutil="$(curl -fsSL https://raw.githubusercontent.com/kcrawford/dockutil/b7fcec8aae863cd83cb27c2cf8bd3e739ece0795/scripts/dockutil)"

python -c "$dockutil" --add "/Applications/Firefox.app" --after Launchpad
python -c "$dockutil" --add "/Applications/VidyoDesktop.app" --after Firefox
python -c "$dockutil" --add "/Applications/Crashplan" --after VidyoDesktop
python -c "$dockutil" --list
