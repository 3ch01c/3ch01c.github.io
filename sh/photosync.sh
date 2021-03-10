#!/bin/bash

printHelp () {
  echo "$1"
  echo "Finds photos rooted in SRC and organizes them into subdirectories of DST by date taken (or else last modified date) in Ymd format, e.g., 20201024."
  echo "Usage: $0 [RSYNC_FLAGS] SRC DST"
  echo "       RSYNC_FLAGS: Rsync flags. See the rsync man page."
  echo "       SRC: source root directory"
  echo "       DST: destination root directory"
  echo ""
  exit 1
}

IMG_REGEX=".*\.(JPG|RAW|MP4|MOV|360|HEIC)"

if [[ $# -lt 2 ]]; then
    printHelp "Not enough arguments"
fi
RSYNC_FLAGS="${@:1:((${#@}-2))}"
SRC_ROOT="${@:(-2):1}"
DST_ROOT="${@:(-1):1}"

#echo find "$SRC_ROOT" -regextype posix-extended -iregex "$IMG_REGEX"
while IFS= read -r SRC
do
  if [[ $SRC == "" ]]; then echo "No images found in $SRC_ROOT" && exit 0; fi
  # https://video.stackexchange.com/questions/7145/capture-date-for-video
  JSON=$(ffprobe -v quiet -print_format json -show_format "$SRC")
  # use creation_time tag if available
  CTIME=$(jq -r '.format.tags.creation_time' <<< "$JSON")
  # else use file modified time
  if [[ $CTIME == "null" ]]; then CTIME=$(stat -c%y "$SRC"); fi
  # convert to Ymd
  CTIME=$(date -d"$CTIME" +%Y%m%d)
  CYEAR=$(date -d"$CTIME" +%Y)
  CMONTH=$(date -d"$CTIME" +%m)
  CDAY=$(date -d"$CTIME" +%d)
  DST="$DST_ROOT/$CYEAR/$CMONTH/${CTIME}/"
  #echo rsync $RSYNC_FLAGS "$SRC" "$DST"
  rsync $RSYNC_FLAGS "$SRC" "$DST"
done <<< $(find "$SRC_ROOT" -regextype posix-extended -iregex "$IMG_REGEX")