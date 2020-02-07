# Modifying songs

Edit ID3 tags.

```sh
INPUT="Artist - Song Title.mp3"
IFS=" - " read -ra $PARTS <<< $INPUT
ARTIST=${PARTS[0]}
TITLE=${PARTS[1]}
ffmpeg -i $INPUT -id3v2_version 3 -write_id3v1 1 -metadata title=$TITLE -metadata artist=$ARTIST -metadata $OUTPUT
```

Add album art.

```sh
ffmpeg -i image.png -map 1 -map 0 -c copy -disposition:0 attached_pic
```
