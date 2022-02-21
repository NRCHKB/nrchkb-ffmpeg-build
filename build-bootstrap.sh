#!/bin/bash

# Colors
Red=$'\e[0;31m'
Yellow=$'\e[1;33m'
End=$'\e[0m'

printf "\033c"

source cat /etc/os-release

if [[ "$ID" = "alpine" ]]; then
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/Alpine-Support/build-alpine.sh)
else
   bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/Alpine-Support/build-ubuntu.sh)
fi

