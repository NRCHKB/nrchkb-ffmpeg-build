#!/bin/bash

# Colors
Red=$'\e[0;31m'
Yellow=$'\e[1;33m'
End=$'\e[0m'

printf "\033c"

if [[ which apt ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/main/build-ubuntu.sh)
elif [[ which apk ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/main/build-alpine.sh)
else
   echo " ${Red}Sorry! ${End}"
fi

