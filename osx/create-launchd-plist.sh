#!/bin/bash

# change to script directory
if [ -z "`readlink ${BASH_SOURCE[0]}`" ]; then
        SCRIPT=${BASH_SOURCE[0]}
else
        SCRIPT=`readlink ${BASH_SOURCE[0]}`
fi
pushd "$( cd "$( dirname "${SCRIPT}" )" && pwd -P )" 1>/dev/null

# define values
TOKEN_USER=`whoami`
TOKEN_SCRIPT="$(cd $(dirname $1) ; pwd)/$(basename $1)"
TARGET_FILE="$(cd $(dirname $2) ; pwd)/$(basename $2)"

# create plist from template
sed "s,TOKEN-USER,$TOKEN_USER,g" ./create-launchd-plist.template | sed "s,TOKEN-SCRIPT,$TOKEN_SCRIPT,g" > $TARGET_FILE

# restore directory
popd 1>/dev/null
