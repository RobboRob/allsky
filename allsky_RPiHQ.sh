#!/bin/bash

echo Starting AllSky for Raspberry Pi HQ camera...
cd /home/pi/allsky

echo Ensuring you are running the latest software...
if [ `git pull | wc -c` != 20 ]; then
	echo Compiling software...
	make
	if [ -f "/etc/raspap/camara_settings.json" ] ; then
		echo Copying camera settings file...
		sudo cp camera_settings.json /etc/raspap
	fi
fi

CAMERA=RPiHQ

echo Making sure allsky_RPiHQ.sh is not already running...
ps -ef | grep allsky_RPiHQ.sh | grep -v $$ | xargs "sudo kill -9" 2>/dev/null

echo Read configured values...
source /home/pi/allsky/config.sh
source /home/pi/allsky/scripts/filename.sh

# Building the arguments to pass to the capture binary
ARGUMENTS=""
KEYS=( $(jq -r 'keys[]' $CAMERA_SETTINGS) )
for KEY in ${KEYS[@]}
do
	ARGUMENTS="$ARGUMENTS -$KEY `jq -r '.'$KEY $CAMERA_SETTINGS` "
done

# When using a desktop environment (Remote Desktop, VNC, HDMI output, etc), a preview of the capture can be displayed in a separate window
# The preview mode does not work if allsky.sh is started as a service or if the debian distribution has no desktop environment.
if [[ $1 == "preview" ]] ; then
	ARGUMENTS="$ARGUMENTS -preview 1"
fi
ARGUMENTS="$ARGUMENTS -daytime $DAYTIME"

echo "$ARGUMENTS">>log.txt

./capture_RPiHQ $ARGUMENTS
