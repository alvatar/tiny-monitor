#/bin/sh

declare -x PROGRAM="bin/monitor"

if [[ -f $PROGRAM ]]
then
	$PROGRAM
else
	echo "Program not found. Please build the program"
fi
