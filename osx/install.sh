#!/bin/bash

# change to script directory
if [ -z "`readlink ${BASH_SOURCE[0]}`" ]; then
        SCRIPT=${BASH_SOURCE[0]}
else
        SCRIPT=`readlink ${BASH_SOURCE[0]}`
fi
pushd "$( cd "$( dirname "${SCRIPT}" )" && pwd -P )" 1>/dev/null

# check if launchd-plist is already installed
echo -n "Checking install state ... "
if [ -f ~/Library/LaunchAgents/bing.wallpaper.update.plist ]; then
	echo "installed."
	exit 1;
fi
echo "not installed."

# create launchd plist and place it into launch agents
echo -n "Creating launchd-plist ... "
./create-launchd-plist.sh ./get-set-wallpaper.sh ~/Library/LaunchAgents/bing.wallpaper.update.plist
if [[ $? != 0 ]]; then
	echo "failed."
	exit 2;
fi
echo "success."

# load plist into launchd
echo -n "Loading launchd-plist ... "
launchctl load ~/Library/LaunchAgents/bing.wallpaper.update.plist
if [[ $? != 0 ]]; then
	echo "failed."
	exit 3;
fi
echo "success."

# restore directory
popd 1>/dev/null

