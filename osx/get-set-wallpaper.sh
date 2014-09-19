#!/bin/bash

# determine if we should sleep
if ! [ -z "$1" ]; then
	echo "Sleeping $1 seconds..."
	sleep $1
fi

# specify market and index
export BING_MARKET=en-WW
export BING_INDEX=0

# change to script directory
if [ -z "`readlink ${BASH_SOURCE[0]}`" ]; then
        SCRIPT=${BASH_SOURCE[0]}
else
        SCRIPT=`readlink ${BASH_SOURCE[0]}`
fi
pushd "$( cd "$( dirname "${SCRIPT}" )" && pwd -P )" 1>/dev/null

# wait for network
echo -n "Waiting for network ... "
./wait-for-network.sh 1>/dev/null 2>&1
if [[ $? != 0 ]]; then
	echo "failed."
	exit 1;
fi
echo "success."

# check if directory is available
echo -n "Checking for target directory ... "
if ! [ -d ./wallpapers ]; then
	mkdir ./wallpapers 1>/dev/null 2>&1
	if [[ $? != 0 ]]; then
		echo "failed to create."
		exit 2;
	fi
	echo "created."
else
	echo "success."
fi

# download current wallpaper
echo -n "Downloading wallpaper from bing.com ... "
./download-bing-wallpaper.sh ./wallpapers/`date +"%Y-%m-%d"`.jpg 1>/dev/null 2>&1
if [[ $? != 0 ]]; then
	echo "failed."
	exit 3;
fi
echo "success."

# set current wallpaper
echo -n "Applying wallpaper to all desktops ... "
./set-wallpaper.sh ./wallpapers/`date +"%Y-%m-%d"`.jpg 1>/dev/null 2>&1
if [[ $? != 0 ]]; then
	echo "failed."
	exit 4;
fi
echo "success."

# restore directory
popd 1>/dev/null
