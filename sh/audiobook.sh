#!/bin/bash

# Convert a MP3 (or directory of MP3s) to a M4B audiobook.
# ./convert-mp3s-to-audiobooks.sh "D:\audiobooks\R. A. Salvatore\04. Legacy of the Drow\Legend of Drizzt - Book 9, Legacy of the Drow, Siege of Darkness.mp3" "D:\audiobooks\R. A. Salvatore\04. Legacy of the Drow/Legend of Drizzt - Book 9, Legacy of the Drow, Siege of Darkness.m4b" "D:\audiobooks\R. A. Salvatore\04. Legacy of the Drow/Legend of Drizzt - Book 9, Legacy of the Drow, Siege of Darkness.jpg" "R. A. Salvatore" "Siege of Darkness" "1993"
# tageditor -s cover="D:\audiobooks\Ed Greenwood\The Elminster Series\02 Elminster in Myth Drannor\Elminster in Myth Drannor Forgotten Realms Elminster, Book 2 (Unabridged).jpg" artist="Ed Greenwood" title="Elminster in Myth Drannor" year="1997" ""D:\audiobooks\Ed Greenwood\The Elminster Series\02 Elminster in Myth Drannor\Elminster in Myth Drannor.m4b"

pid=$$ # pid of script
src=$1 # path of source mp3 or directory
dst=$2 # output audiobook file path

art=$3 # path of book art
author=$4
title=$5
year=$

#for f in "$src"/*.mp3; do echo "file '$src/$f'"; done

if [[ -d $src ]]; then
  list="tracklist-$pid.txt"
  echo $list
  # convert a pile of mp3s to m4b
  #for f in "$src"/*.mp3; do echo "file '$src/$f'"; done
  #rm -rf $list
  find "$src" -name '*.mp3' -printf "file '%p'\n" >> "$list"
  #echo "ffmpeg -f concat -safe 0 -i <(for f in $src/*.mp3; do echo \"file '$src\$f'\"; done) -c copy \"$dst\""
  ffmpeg -f concat -safe 0 -i "$list" -c copy -c:a aac -strict experimental -b:a 64k -f mp4 "$dst"
else
  # convert a mp3 to m4b
  #ffmpeg -i "$src" -c copy -c:a aac -strict experimental -b:a 64k -f mp4 "$dst"
  ffmpeg -i "$src" "$dst"
fi

tageditor -s cover="$cover" artist="$author" title="$title" year="$year" --max-padding 100000 -f "$dst"
