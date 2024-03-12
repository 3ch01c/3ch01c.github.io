#!/bin/bash
# Find all files, print md5, last modified date, file size, user:group, and file type
find . -type f -print0 | xargs -0 -I{} bash -c 'md5sum -z "{}" && echo -ne "\t" && stat -f "%Sm %z %u:%g " -t "%Y-%m-%d %H:%M:%S%z" "{}" | tr -d "\n" && echo -ne "\t" && file -b "{}"' > /Users/james/data/prad/pradusers_file_info.txt 2>/dev/null
