#!/bin/bash

cp "${DINOPATH}/dino-wallpaper.png" "/Users/Shared/dino-wallpaper.png"
echo "We're setting the dang wallpaper now."
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/dino-wallpaper.png"'
