#!/bin/bash
# =============================================================================
# This script can download Bing wallpapers from the web.
# =============================================================================

# -----------------------------------------------------------------------------
# check if all needed applications are installed
# -----------------------------------------------------------------------------
type crontab 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo -e "ERROR: 'crontab' is not installed."
	exit 1;
fi
type at 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo -e "ERROR: 'at' is not installed."
	exit 1;
fi
type curl 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo -e "ERROR: 'curl' is not installed."
	exit 1;
fi


# -----------------------------------------------------------------------------
# common defintions
# -----------------------------------------------------------------------------
scriptName="$(basename $0)"
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# check parameters
if [ -z "$scriptName" ]; then
	echo -e "failed (could not determine script name)."
	exit 1;
fi
if [ -z "$scriptPath" ]; then
	echo -e "failed (could not determine script path)."
	exit 1;
fi

# set login script location and path
loginScriptLocation="~/Library/LaunchAgents"
loginScriptPath="$loginScriptLocation/schedule$scriptName"


# -----------------------------------------------------------------------------
# install routine
# -----------------------------------------------------------------------------
if [ "$1" = "install" ]; then
	echo -ne "Installing..."

	# execute every day one minute after 8 am and 9 am
	crontab -l | grep -v $scriptName | crontab -
	(crontab -l; echo "1 8,9 * * * $scriptPath/$scriptName $2 >/dev/null 2>&1" ) | crontab -

	# execute when user loggin in
	pushd $loginScriptLocation 1>/dev/null 2>&1
		echo "#!/bin/bash" 1>"schedule$scriptName" 2>/dev/null
		echo "echo \"$scriptPath/$scriptName $2\" | at now +1 min -M" 1>>"schedule$scriptName" 2>/dev/null
		chmod +x "schedule$scriptName"
	popd 1>/dev/null 2>&1

	# finished
	echo -e "finished."
	exit 0;
fi


# -----------------------------------------------------------------------------
# uninstall routine
# -----------------------------------------------------------------------------
if [ "$1" = "uninstall" ]; then
	echo -ne "Uninstalling..."

	# uninstall crontab job
	crontab -l | grep -v $scriptName | crontab -

	# uninstall login script
	pushd ~/.kde/env/ 1>/dev/null 2>&1
		rm -f "schedule$scriptName"
	popd 1>/dev/null 2>&1

	# finisehd
	echo -e "finished."
	exit 0;
fi


# -----------------------------------------------------------------------------
# downloader routine
# -----------------------------------------------------------------------------
if [ -z "$1" ]; then
	echo -e "ERROR: specify desired picture file."
	exit 1;
fi

# define picture path
pictureFilePath="$(cd $(dirname $1) ; pwd)/$(basename $1)"

# define log name
logFilePath="${pictureFilePath}.log"

# create log file and write header
echo "" 1>$logFilePath 2>&1
echo "==== BING WALLPAPER DOWNLOADER ====" 1>>$logFilePath 2>&1
echo "" 1>>$logFilePath 2>&1

# URL prefix
prefixUrl="http://www.bing.com"

# Define the market of the picture
# (en-WW, en-US, zh-CN, ja-JP, en-AU, en-UK, de-DE, en-NZ, en-CA)
if [ -z "$BING_MARKET" ] ; then
	market="en-WW"
else
	market=$BING_MARKET
fi

# Define picture index
# ('0' means today, '1' means yesterday, ...)
if [ -z "$BING_INDEX" ] ; then 
	index="0"
else
	index=$BING_INDEX
fi
#index="$(date +"%M")"

# $xmlURL is needed to get the xml data from which
# the relative URL for the Bing pic of the day is extracted
xmlUrl=$prefixUrl"/HPImageArchive.aspx?format=xml&idx=$index&n=1&mkt=$market"

# Create saveDir if it does not already exist
mkdir -p $(dirname $pictureFilePath) 1>>$logFilePath 2>&1

# Iterate until we get a valid image (sometimes not all resolutions are available)
for picRes in _1920x1200 _1366x768 _1280x720 _1024x768; do

	# Extract the picture URL from the downloaded XML
	pictureUrl=$prefixUrl$(echo $(curl -s $xmlUrl) | grep -oE "<urlBase>(.*)</urlBase>" | cut -d ">" -f 2 | cut -d "<" -f 1)$picRes".jpg"

	echo "URL  = $pictureUrl"  1>>$logFilePath 2>&1
	echo "File = $pictureFilePath"  1>>$logFilePath 2>&1
	echo "" 1>>$logFilePath 2>&1

	# Download and save the URL
	curl -o $pictureFilePath $pictureUrl 1>>$logFilePath 2>&1

	# Check if downloaded file is of type JPEG
	if ( file $pictureFilePath | grep JPEG ); then
		# success, we are finished
		break;
	fi

	# delete current file
	rm -rf $pictureFilePath

done

# Exit the script with error in case we still downloaded a HTML file
# (no additional resolutions available)
if !( file $pictureFilePath | grep JPEG ); then
	echo -e "\nFailed to download bing picture.\n"
	echo -e "\nFailed to download bing picture.\n"   1>>$logFilePath 2>&1
	exit 1
fi

# Exit the script with success
echo -e "\nSuccessfully downloaded bing picture of today.\n"
echo -e "\nSuccessfully downloaded bing picture of today.\n"   1>>$logFilePath 2>&1
exit 0
