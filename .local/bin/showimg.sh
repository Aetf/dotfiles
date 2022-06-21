#!/bin/bash

shopt -s lastpipe
COLS=$(tput cols)
for image in "$@"; do
  declare -a u d
  u=()
  d=()
  convert -thumbnail $COLS "$image" txt:- |
  while IFS=',:() ' read c l dummy r g b rest; do
    if [ "$c" = "#" ]; then
      continue
    fi
    if [ $((l%2)) = 0 ]; then
      u[$c]="$r;$g;$b"
    else
      d[$c]="$r;$g;$b"
    fi
    if [ $((l%2)) = 1 -a $c = $((COLS-1)) ]; then
      i=0
      while [ $i -lt $COLS ]; do
        echo -ne "\\e[38;2;${u[$i]};48;2;${d[$i]}m▀"
        i=$((i+1))
      done
      echo -e "\\e[0m"
      u=()
      d=()
    fi
  done
  if [ "${u[0]}" != "" ]; then
    i=0
    while [ $i -lt $COLS ]; do
      echo -ne "\\e[38;2;${u[$i]}m▀"
      i=$((i+1))
    done
    echo -e "\\e[0m"
  fi
done