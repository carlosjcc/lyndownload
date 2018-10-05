#!/bin/bash

# regex declaration
section_regex="<h4.*toc\-chapter.*>(.*)<"
videos_regex="<a href=\"(.*)\".*class=\"item-name video-name ga\".*>"
name_regex="[ \'a-zA-Z]*"
sect_regex="[0-9]+.*"

# command line arguments
# course link
course_link="$1"

# course path
course_path="$2"

# main html name
course_main="course_main.html"

# create new course folder
if [[ ! -d "$course_path" ]]; then
  mkdir "$course_path"
fi

# globals
prev_sect=""
sect=""

last_sect=""
vid_name=""
vid_add=""
vid_num=1

# download the course main website
wget --output-document="$course_path/course_main.html" $course_link

# info of all sections and videos
info=`grep -A 1 -e "<h4.*toc\-chapter.*>.*<" -e "<a href=\".*\".*class=\"item-name video-name ga\".*>" "$course_path/course_main.html" |\
      grep -v "</div>" |\
      sed -e 's/^\s*//' -e '/^$/d' -e 's/--//' -e '/^\s*$/d'`

# read info of the course and parse
while read -r line; do

  # new section
  if [[ $line =~ $section_regex ]]; then

    if [[ -f "$course_path/$sect/temp.html" ]]; then
      rm "$course_path/$sect/temp.html"
    fi

    # restart video count per section
    vid_num=1

    # get name of section
    sect="${BASH_REMATCH[1]}"    

    # keep track of last numbered section to rename conclusion with a number
    if [[ $sect =~ $sect_regex ]]; then
      last_sect=`echo $sect | sed 's/\([0-9]*\)\..*$/\1/'`      
    fi

    # make folder for the new section and change to it
    mkdir "$course_path/$sect"

  # otherwise get video address
  elif [[ $line =~ $videos_regex ]]; then
    # addres of the video
    vid_add="${BASH_REMATCH[1]}"

  # if we find a name we got the name and the video address, we can download it!
  elif [[ $line =~ $name_regex ]]; then
    vid_name="$line"

    # download html do get vids address
    wget --output-document="$course_path/$sect/temp.html" --load-cookies ~/Downloads/cookies.txt "$vid_add"

    # get line of code from temp.html, get the url, change "amp;" for nothing THATS THE VIDs URL! BINGO!!!
    vid_url=`grep -e "data-src=\"https://lynda" -e "data-src=\"https://files[0-9]\.lynda" "$course_path/$sect/temp.html" |\
             cut -f2 -d\" |\
             sed 's/amp;//'`

    # download video. when it fails $vid_url is empty!!!!!!!!!!
    wget --output-document="$course_path/$sect/$vid_num. $vid_name" "$vid_url"

    # keeping track of num of vid within each section
    ((vid_num++))

  fi
done <<< "$info"

# remove temp from last downloaded section
if [[ -f "$course_path/$sect/temp.html" ]]; then
  rm "$course_path/$sect/temp.html"
fi

# cleanup
rm "$course_path/course_main.html"

# rename Introduction
if [[ -d "$course_path/$sect/Introduction" ]]; then
  mv "$course_path/Introduction" "$course_path/0. Introduction"
fi

((last_sect++))

# rename Conclusion
if [[ -d "$course_path/Conclusion" ]]; then
  mv "$course_path/Conclusion" "$course_path/$last_sect. Conclusion"
fi


