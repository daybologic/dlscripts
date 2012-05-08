#!/bin/ksh

OLDUSERID=500
NEWUSERID=1100
LISTFILE=/tmp/$OLDUSERID_files.lst

find / -user $OLDUSERID > $LISTFILE
while read line
do
 chown $NEWUSERID $line
done <$LISTFILE

exit 0
