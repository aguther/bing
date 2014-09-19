#!/bin/bash

# set wallpaper to a solid color to ensure the new wallpaper is being set (e.g. when using same filename)
osascript -e 'tell application "System Events" to set picture of every desktop to "/Library/Desktop Pictures/Solid Colors/Solid Gray Pro Ultra Dark.png"'
if [[ $? != 0 ]]; then
	exit 1;
fi

# let system set the wallpaper
sleep 1
if [[ $? != 0 ]]; then
	exit 2;
fi

# determine absolute path of file
IMAGE_FILE_PATH="$(cd $(dirname $1) ; pwd)/$(basename $1)"

# set the desired wallpaper
osascript -e "tell application \"System Events\" to set picture of every desktop to \"${IMAGE_FILE_PATH}\""
if [[ $? != 0 ]]; then
	exit 3;
fi

exit 0;
