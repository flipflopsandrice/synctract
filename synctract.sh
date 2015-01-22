#!/bin/sh

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
CONFIGFILE="$SCRIPTPATH/"config.cfg

## Import configuration
if [ ! -f "$CONFIGFILE" ]
then
    echo No configuration file found, exiting.
    exit;
fi

eval $(sed '/:/!d;/^ *#/d;s/:/ /;' < "$CONFIGFILE" | while read -r key val
do
    str="$key='$val'"
    echo "$str"
done)

if [ "$logging_enabled" -eq 1 ]
then
    echo Started sequence on: `date`
fi

IGNORELIST="$local_tmp"/synctract.ignore

### Check for lock (= running instance)
if [ -f "$local_tmp"/synctract.lock ]
then
    echo "Lock found, exiting."
    exit;
fi
touch "$local_tmp"/synctract.lock
touch "$IGNORELIST"

### Rsync data
rsync -avzq --bwlimit=1536 --specials --ignore-errors --exclude-from "$IGNORELIST" "$remote_user"@"$remote_hostname":"$remote_folder"/ "$local_destination"
find "$local_destination" | sed "s#$local_destination/##g" >> "$IGNORELIST"

### Find available archives
RARS=`find "$local_destination" | grep .rar | sed "s#$local_destination/##g" | grep -v "@eaDir"`
for RAR in `echo "$RARS"`
do
    CONTENTS=`unrar l "$local_destination"/"$RAR" | grep -o ':[0-9]\{2\}\ \ \(.*\)$' | awk '{printf $2 "\n"}'`
    MISSING=""
    for CONTENT in `echo "$CONTENTS"`
    do
        FOUND=`find "$local_destination" | grep "$CONTENT$"`
        if [ -z "$FOUND" ]
        then
            MISSING=1;
            echo ""
        fi
    done

    if [ ! -z "${MISSING}" ]
    then
        unrar x "$local_destination"/"$RAR" `dirname "$local_destination"/"$RAR"` > /dev/null 2>&1
        
        if [ "$logging_enabled" -eq 1 ]
        then
            echo Extracting '"$RAR"'
        fi
    fi
done

### Release lock
rm "$local_tmp"/synctract.lock;

if [ "$logging_enabled" -eq 1 ]
then
    echo Lock released on: `date`
fi

