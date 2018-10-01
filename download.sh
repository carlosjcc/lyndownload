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
course="$1"

section_regex="<h4.*toc\-chapter.*>(.*)<"
# videos_regex="\s*<a href=\"(.*)\">\s+(.*)"
videos_regex="<a href=\"(.*)\".*class=\"item-name video-name ga\".*>"
name_regex="[ \'a-zA-Z]*"
flag="0"

sect=""
vid_name=""
vid_add=""

# download the course main website
wget -O "$course_main" $course

# info of all sections of videos of each section
var=`grep -e "<h4.*toc\-chapter.*>.*<" -A 1 -e "<a href=\".*\".*class=\"item-name video-name ga\".*>" course_main.html | grep -v "</div>" | sed -e 's/^\s*//' -e '/^$/d' -e 's/--//' -e '/^\s*$/d'`


while read -r line; do

  # echo "$line"

  # new section
  if [[ $line =~ $section_regex ]]; then
    sect="${BASH_REMATCH[1]}"
    echo "$sect"
    # make folder for the new section and change to it
    mkdir "$sect" # && cd "$sect"


  # otherwise get video address
  elif [[ $line =~ $videos_regex ]]; then
    # addres of the video
    vid_add="${BASH_REMATCH[1]}"

  # if we find a name we got the name and the video address, we can download it!
  elif [[ $line =~ $name_regex ]]; then
    vid_name="$line"

    # download html do get vids address
    wget --output-document="$root_dir/$sect/temp.html" --load-cookies cookies.txt "$vid_add"

    # get line of code from temp.html, get the url, change amp; for nothing THATS THE VIDs URL! BINGO!!!
    vid_url=`grep "data-src=\"https://lynda" "$root_dir/$sect/temp.html" | cut -f2 -d\" | sed 's/amp;//'`

    wget --output-document="$root_dir/$sect/$vid_name" "$vid_url"

    # echo "$vid_name"
    # echo "$vid_add"
    # echo ""
  fi
done <<< "$var"

# while read line; do

#   # echo "hola"
#   # if [[ $flag == "1" ]]; then
#   #   # echo "tomela"
#   #   echo "name:  $line"
#   #   echo "link: $vid"
#   #   flag="0"
#   # fi

#   # new secion?
#   if [[ $line =~ $section_regex ]]; then

#     # go to "root" dir
#     cd "$root_dir"

#     # get name of the section
#     sect="${BASH_REMATCH[1]}"

#     # make folder for the new section and change to it
#     mkdir "$sect" # && cd "$sect"

#   fi

#   if [[ $line =~ $videos_regex ]]; then

#     # addres of the video
#     vid="${BASH_REMATCH[1]}"

#     # download html do get vids address
#     wget --output-document="$root_dir/$sect/temp.html" --load-cookies cookies.txt "$vid"

#     # get line of code from temp.html, get the url, change amp; for nothing THATS THE VIDs URL! BINGO!!!
#     vid_url=`grep "data-src=\"https://lynda" "$root_dir/$sect/temp.html" | cut -f2 -d\" | sed 's/amp;//'`

#     # wget --output-document="$root_dir/$sect/temp.html"
#   fi
# done < $course_main