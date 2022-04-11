#!/bin/bash

# Clear Terminal
printf "\033c"

# OSX
if [[ "$OSTYPE" == "darwin"* ]]; then
   if [[ $(which brew) ]]; then
      bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/main/build-osx.sh) "$@"
   else
      echo
      echo "----------------------------------------------------------------------------------------------------"
      echo "| OSX environments require 'brew' to be installed, and for it to be included in the PATH variable. |"
      echo "----------------------------------------------------------------------------------------------------"
      echo
      exit 0
   fi
   exit 0
# Apline
elif [[ $(which apk) ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/main/build-alpine.sh) "$@"
   exit 0
# Debian
elif [[ $(which apt) ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/main/build-debian.sh) "$@"
   exit 0
fi
