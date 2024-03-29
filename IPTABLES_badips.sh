#!/bin/bash
# Script for blocking IPs which have been reported to www.badips.com
# Usage: Just execute with root privileges
# ---------------------------

_file=/etc/hosts.deny  # Location of the hosts.deny files (might be correct)
_input=badips.db       # Name of database (will be downloaded with this name)
_level=4               # Blog level: not so bad/false report (0) over confirmed bad (3) to qui$
_service=any           # Logged service (see www.badips.com for that)
_tmp=tmp               # Name of temporary file

# Get the bad IPs
wget -qO- http://www.badips.com/get/list/${_service}/$_level?age=2w > $_input || { echo "$0: Unable to download ip list."; exit 1; }

# Define some start and end quotes for detecting the IPs defined by this script
_start="# ##### start block list -- DO NOT EDIT #####"
_end="# ##### end block list #####"

# Delete the old entries
_line_start=`grep -x -n "$_start" $_file | cut -f1 -d:`
_line_end=`grep -x -n "$_end" $_file | cut -f1 -d:`
_lines=`wc -l < $_file`

# Chop the old block if it exists
if [[ "$_line_start" != " " ]]
then
    head -n`expr $_line_start - 1` $_file > $_tmp
    tail -n`expr $_lines - $_line_end` $_file >> $_tmp
else
    cp $_file $_tmp
fi

# Add the new entries
echo $_start >> $_tmp
cat $_input | sed "s/^/ALL\:\ /g" >> $_tmp
echo $_end >> $_tmp

# Replace and cleanup the old file
mv $_tmp $_file
rm $_input

exit 0
