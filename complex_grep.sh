#!/bin/bash

var=`grep -e "<h4.*toc\-chapter.*>.*<" -A 1 -e "<a href=\".*\".*class=\"item-name video-name ga\".*>" course_main.html | grep -v "</div>" | sed -e 's/^\s*//' -e '/^$/d' -e 's/--//' -e '/^\s*$/d'`

echo "$var" | wc -l

# echo "$var"

section_regex="<h4.*toc\-chapter.*>(.*)<"
videos_regex="<a href=\"(.*)\".*class=\"item-name video-name ga\".*>"
name_regex="[ \'a-zA-Z]*"

sect=""
vid_name=""
vid_add=""

while read -r line; do

  # echo "$line"

  # new section
  if [[ $line =~ $section_regex ]]; then
    sect="${BASH_REMATCH[1]}"
    echo "$sect"

  # otherwise get video address
  elif [[ $line =~ $videos_regex ]]; then
    # addres of the video
    vid_add="${BASH_REMATCH[1]}"

  # if we find a name we got the name and the video address, we can download it!
  elif [[ $line =~ $name_regex ]]; then
    vid_name="$line"
    echo "$vid_name"
    echo "$vid_add"
    echo ""
  fi
done <<< "$var"