#!/usr/local/bin/bash -x

set -e

DISC_LENGTH_SEC=3600

[[ $# -eq 0 ]] && { echo "Usage: $0 mp3file"; exit 1; }
source="$1"
base=${source%.*}
full="$base.wav"
[[ ! -f $full ]] && { mpg123 -w "$full" "$source"; }

seconds=`sox "$full" -n stat 2>&1 | grep "Length (seconds):" | cut -d' ' -f 4`
seconds=${seconds%.*}
let seconds=seconds+1
echo "Audio is $seconds seconds"
discCount=$(($seconds / $DISC_LENGTH_SEC))
let discCount=discCount+1
echo "Will split into $discCount discs"

discI=0
while [ $discI -lt $discCount ]; do
	let discN=discI+1
	startSec=$(($DISC_LENGTH_SEC * $discI))
	let endSec=startSec+DISC_LENGTH_SEC
	let endSec=endSec-1
	sox "$full" "$base.disc$discN.wav" trim $startSec =$endSec;
	let discI=discI+1
done

exit 0
