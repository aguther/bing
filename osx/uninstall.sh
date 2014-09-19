#!/bin/bash

# change to script directory
if [ -z "`readlink ${BASH_SOURCE[0]}`" ]; then
        SCRIPT=${BASH_SOURCE[0]}
else
        SCRIPT=`readlink ${BASH_SOURCE[0]}`
fi
pushd "$( cd "$( dirname "${SCRIPT}" )" && pwd -P )" 1>/dev/null

# check if launchd-plist is installed
echo -n "Checking install state ... "
if ! [ -f ~/Library/LaunchAgents/bing.wallpaper.update.plist ]; then
	echo "not installed."
	exit 1;
fi
echo "installed."

# unload launchd-plist
echo -n "Unloading launchd-plist ... "
launchctl unload ~/Library/LaunchAgents/bing.wallpaper.update.plist
if [[ $? != 0 ]]; then
	echo "failed."
	exit 2;
fi
echo "success."

# remove launchd-plist
echo -n "Removing launchd-plist ... "
rm -rf ~/Library/LaunchAgents/bing.wallpaper.update.plist
if [[ $? != 0 ]]; then
	echo "failed."
	exit 3;
fi
echo "success."

# restore directory
popd 1>/dev/null
