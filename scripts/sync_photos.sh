#!/bin/bash

printHelp () {
  echo "$1"
  echo "Usage: $0 [-v] INPUT OUTPUT"
  echo "       INPUT: source directory"
  echo "       OUTPUT: output directory"
  echo ""
  exit 1
}

IMG_REGEX=".*\.(JPG|RAW|MP4|MOV|360)"

if [[ $# -lt 2 ]]; then
    printHelp "Not enough arguments"
fi
while [[ $# -gt 1 ]]; do
	key="$1"
	case "$key" in
		-h|--help) printHelp ;;
    -v|--verbose) VERBOSE=1 ;;
    --delete) DELETE=1 ;;
		*) SRC_ROOT="$1"; DST_ROOT="$2"
	esac
	shift
done

if [ ! -z ${VERBOSE+x} ]; then echo find "$SRC_ROOT" -regextype posix-extended -iregex "$IMG_REGEX"; fi
while IFS= read -r IMG
do
  # https://video.stackexchange.com/questions/7145/capture-date-for-video
  JSON=$(ffprobe -v quiet -print_format json -show_format "$IMG")
  CTIME=$(jq -r '.format.tags.creation_time' <<< "$JSON")
  if [[ $CTIME == "null" ]]; then CTIME=$(stat -c%y "$IMG"); fi
  # convert to Ymd
  CTIME=$(date -d"$CTIME" +%Y%m%d)
  CYEAR=$(date -d"$CTIME" +%Y)
  CMONTH=$(date -d"$CTIME" +%m)
  CDAY=$(date -d"$CTIME" +%d)
  DST="$DST_ROOT/$CYEAR/$CMONTH/${CTIME}/"
  echo "$IMG: $DST"
  FLAGS="-az"
  if [ ! -z ${VERBOSE+x} ]; then FLAGS+=" -P"; fi
  if [ ! -z ${DELETE+x} ]; then FLAGS+=" --remove-source-files"; fi
  rsync $FLAGS "$IMG" "$DST"
done <<< $(find "$SRC_ROOT" -regextype posix-extended -iregex "$IMG_REGEX")