#!/bin/bash

# regex declaration
section_regex="<h4.*toc\-chapter.*>(.*)<"
videos_regex="<a href=\"(.*)\".*class=\"item-name video-name ga\".*>"
name_regex="[ \'a-zA-Z0-9]*"
sect_regex="[0-9]+.*"
exer_fl_rgx="href=\"(/ajax/course/[0-9]*/download/exercise/[0-9]*)\""
course_name_rgx="<title>(.*)</title>"

# command line arguments
# course link
course_link="$1"

# course path
download_path="$2"


# globals
prev_sect=""
sect=""

last_sect=""
vid_name=""
vid_add=""
vid_num=1
course_name=""
n=1

# download the course main website
wget -c --output-document="$download_path/course_main.html" --load-cookies ~/Downloads/cookies.txt --quiet $course_link

# get title of the course
title=`grep "<title>.*</title>" "$download_path/course_main.html"`

# get course name
if [[ $title =~ $course_name_rgx ]]; then
  course_name="${BASH_REMATCH[1]}"
fi

# create new course folder
if [[ ! -d "$download_path/$course_name" ]]; then
  mkdir "$download_path/$course_name"
fi

# move main html to new folder
mv "$download_path/course_main.html" "$download_path/$course_name"

# path to the course folder
course_path="$download_path/$course_name"

# get the line with the exercise files
ex_file_line=`grep "href=\"/ajax/course/[0-9]*/download/exercise/[0-9]*\"" "$course_path/course_main.html"`

# download exercise files, if any
if [[ $ex_file_line =~ $exer_fl_rgx ]]; then
  ex_file_add="${BASH_REMATCH[1]}"
  wget -c --load-cookies ~/Downloads/cookies.txt --output-document="$course_path/excFiles.zip" --quiet --show-progress "https://www.lynda.com/$ex_file_add"
fi

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
    sect=`echo "$sect" | sed 's/\//-/'`

    # keep track of last numbered section to rename conclusion with a number
    if [[ $sect =~ $sect_regex ]]; then
      last_sect=`echo $sect | sed 's/\([0-9]*\)\..*$/\1/'`      
    fi

    # make folder for the new section and change to it
    if [[ ! -d "$course_path/$sect" ]]; then
      mkdir "$course_path/$sect"
    fi

  # otherwise get video address
  elif [[ $line =~ $videos_regex ]]; then
    # addres of the video
    vid_add="${BASH_REMATCH[1]}"

  # if we find a name we got the name and the video address, we can download it!
  elif [[ $line =~ $name_regex ]]; then

    # change names containing forward slash for a hyphen
    vid_name=`echo "$line" | sed 's/\//-/'`

    # download html do get vids address | this could be a bug if the html didnt download fully
    if [[ ! -f "$course_path/$sect/$vid_num. $vid_name.html" ]]; then
      wget -c --output-document="$course_path/$sect/$vid_num. $vid_name.html" --load-cookies ~/Downloads/cookies.txt --quiet "$vid_add"
    fi    

    # get line of code from temp.html, get the url, change "amp;" for nothing THATS THE VIDs URL! BINGO!!!
    vid_url=`grep -e "data-src=\"https://lynda" -e "data-src=\"https://files[0-9]\.lynda" "$course_path/$sect/$vid_num. $vid_name.html" |\
             cut -f2 -d\" |\
             sed 's/amp;//'`
    
    # fails if file has / in name
    wget -c --output-document="$course_path/$sect/$vid_num. $vid_name" --quiet --show-progress "$vid_url"

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
if [[ -d "$course_path/Introduction" ]]; then
  mv "$course_path/Introduction" "$course_path/0. Introduction"
fi

((last_sect++))

# rename Conclusion
if [[ -d "$course_path/Conclusion" ]]; then
  mv "$course_path/Conclusion" "$course_path/$last_sect. Conclusion"
fi


# we finished
echo -ne '\007'
echo -ne '\007'
echo -ne '\007'
