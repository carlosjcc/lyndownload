#!/bin/bash

# <a\s+|<h4

# main html name
course_main="course_main.html"

# course link
course="$1"

regex="<h4.*toc\-chapter.*>(.*)<"

wget -O "$course_main" $course

while read line; do
  # printf "$line"
  if [[ $line =~ $regex ]]; then
    chap="${BASH_REMATCH[1]}"
    echo "$chap"
  fi
done < $course_main