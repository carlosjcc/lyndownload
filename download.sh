#!/bin/bash

# z5032935@ad.unsw.edu.au 15corrale$

# https://www.lynda.com/signin/link-social
# name email carloscorralesch@gmail.com  
# password 15CARlos

# <a\s+|<h4

# downloading course
root_dir=`pwd`
# echo "$root_dir"

# main html name
course_main="course_main.html"

# course link
course_link="$1"
course_path="$2"


section_regex="<h4.*toc\-chapter.*>(.*)<"
# videos_regex="\s*<a href=\"(.*)\">\s+(.*)"
videos_regex="<a href=\"(.*)\".*class=\"item-name video-name ga\".*>"
name_regex="[ \'a-zA-Z]*"
sect_regex="[0-9]+.*"


flag="0"

sect=""
last_sect=""
vid_name=""
vid_add=""
vid_num=1

# download the course main website
wget -O "$course_path/$course_main" $course_link

# info of all sections of videos of each section
var=`grep -e "<h4.*toc\-chapter.*>.*<" -A 1 -e "<a href=\".*\".*class=\"item-name video-name ga\".*>" course_main.html | grep -v "</div>" | sed -e 's/^\s*//' -e '/^$/d' -e 's/--//' -e '/^\s*$/d'`


while read -r line; do

  # new section
  if [[ $line =~ $section_regex ]]; then

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
    vid_url=`grep -e "data-src=\"https://lynda" -e "data-src=\"https://files[0-9]\.lynda" "$course_path/$sect/temp.html" | cut -f2 -d\" | sed 's/amp;//'`

    # debug
    # download video
    # echo -e "*****************************************"
    # echo -e "vid address $vid_url"
    # echo -e "*****************************************"

    # if [[ $vid_url = "" ]]; then
    #   exit
    # fi

    # while [[ $vid_url = "" ]]; do
    #   vid_url=`grep "data-src=\"https://lynda" "$root_dir/$sect/temp.html" | cut -f2 -d\" | sed 's/amp;//'`
    # done

    # download video. when it fails $vid_url is empty!!!!!!!!!!
    wget --output-document="$course_path/$sect/$vid_num. $vid_name" "$vid_url"

    # keeping track of num of vid within each section
    ((vid_num++))

  fi
done <<< "$var"

# cleanup
rm "$course_path/course_main.html"

mv "$course_path/Introduction" "$course_path/0. Introduction"

((last_sect++))

mv "$course_path/Conclusion" "$course_path/$last_sect. Conclusion"



# ls | egrep "^[0-9]+.*"