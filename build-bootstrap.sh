#!/bin/bash

# nrchkb-ffmpeg-build Version 2.1

# Copyright (c) 2022-2024 Marcus Davies
# Copyright (c) 2022-2024 Garrett Porter

# MIT License

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
# Alpine
elif [[ $(which apk) ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/$BRANCH_NAME/build-alpine.sh) "$@"
   exit 0
# Debian
elif [[ $(which apt) ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/$BRANCH_NAME/build-debian.sh) "$@"
   exit 0
fi
