#!/bin/bash

# Override Branch?
if [[ -z "${BRANCH_NAME}" ]]; then
  BRANCH_NAME="main"
fi

# Clear Terminal
printf "\033c"

# OSX
if [[ "$OSTYPE" == "darwin"* ]]; then
   if [[ $(which brew) ]]; then
      bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/$BRANCH_NAME/build-osx.sh) "$@"
   else
      echo
      echo " ----------------------------------------------------------------------------------------"
      echo " |                 OSX environments require 'brew' to be installed,                     |"
      echo " |              and for it's path to be included in the PATH variable'.                 |"
      echo " ----------------------------------------------------------------------------------------"
      echo
      exit 0
   fi
   exit 0
# Apline
elif [[ $(which apk) ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/$BRANCH_NAME/build-alpine.sh) "$@"
   exit 0
# Debian
elif [[ $(which apt) ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/$BRANCH_NAME/build-debian.sh) "$@"
   exit 0
fi
