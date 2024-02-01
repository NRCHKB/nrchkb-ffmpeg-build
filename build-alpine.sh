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

# Colors
Red=$'\e[0;31m'
Yellow=$'\e[1;33m'
End=$'\e[0m'

# Defaults
JOBS=3           # Jobs Value
JOBS_PARAM=false  # Arg provided

FDK="y"          # FDK Choice Value
FDK_PARAM=false   # Arg provided

L264="y"         # 264 Choice Value
L264_PARAM=false  # Arg provided

L265="n"         # 265 Choice Value
L265_PARAM=false  # Arg provided

LVPX="n"         # VPX Choice Value
LVPX_PARAM=false   # Arg provided

LOPUS="n"        # Opus Choice Value
LOPUS_PARAM=false # Arg provided

FLAGSYN="n"      # Flags Choice Value
FLAGS=""         # Flags Value
FLAGS_PARAM=false # Arg provided

MODE=0           # Mode Value
MODE_PARAM=false  # Arg provided

INTERACTIVE="y"  # Interactive

# Prefix
PREFIX="/usr/local"
export LDFLAGS="-L$PREFIX/lib"
export CFLAGS="-I$PREFIX/include"

# Ignore Repository sources
FORCE_BUILD=false

# Specific package manager implementation
INSTALL() {
    apk add $@
}
REMOVE() {
    apk del "$1"
}
CHECK() {
    apk info "$1"
}

# Package Names
DEP_X264="x264-dev"
DEP_X265="x265-dev"
DEP_VPX="libvpx-dev"
DEP_OPUS="opus-dev"
DEP_AAC="fdk-aac-dev"

# Print Header
printHeader() {

    printf "\033c"
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                   2.1 |"
    echo " |          P&M FFmpeg Build Script (Alpine)             |"
    echo " |   An FFmpeg build & installation utility for NRCHKB   |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    echo " ${Yellow}Note: This script will install into $PREFIX/bin and $PREFIX/lib respectively.${End}"
    echo

}

# Print menu
menu() {

    echo " ${Yellow}What would you like to do:${End}"
    echo
    echo "   1 - Install build tools (Dependencies from apt)"
    echo "   2 - Build/install libfdk-aac (AAC Audio Encoder)"
    echo "   3 - Build/install libx264 (x264 Video Encoder)"
    echo "   4 - Build/install libx265 (x265 Video Encoder)"
    echo "   5 - Build/install libvpx (VP8/VP9 video Encoder/Decoder)"
    echo "   6 - Build/install libopus (Opus Audio Encoder/Decoder)"
    echo "   7 - Build FFmpeg (Builds from source only)"
    echo "   8 - Guided Install"
    echo "   9 - Purge build directories"
    echo "   q - Quit"
    echo
    echo "   Note: This script will download and compile these software packages from source code,"
    echo "         unless they happen to be available from your systems repository."
    echo "         Where necessary, libraries will be built as shared libs."
    echo
    echo "         This excludes FFMPEG which will always be built for source."
    echo
    echo "         If you have previously run this script, running it again will update your software."
    echo
    printf "   Choice: "
    read -r
    if [[ "$REPLY" = "q" ]]; then
        exit 0
    fi

    MODE=$REPLY

    if [[ $MODE -gt 8 || $MODE -lt 1 ]]; then
        printHeader
        menu
    fi
    processOptions "$MODE"
}

# Error Check
checkForError() {
    if [[ $? -gt 0 ]]; then
        stopWatch "stop"
        echo "${Red}"
        echo " ---------------------------------------------------------"
        echo " |                                                       |"
        echo " |                   Errors occurred                     |"
        echo " |        Please check the logs and try again            |"
        echo " |                                                       |"
        echo " ---------------------------------------------------------"
        echo "${End}"
        echo
        exit 1
    fi
}

# Install Dependencies
installDependencies() {
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |               Installing Dependencies                 |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    INSTALL pkgconfig autoconf automake libtool git wget make g++ gcc nasm yasm build-base cmake diffutils

}

# Install Libx264
installLibx264() {
    cd ~ || { echo "Failed to cd ~"; exit 1; }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Building/Installing libx264              |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    if [[ $FORCE_BUILD = false ]]; then
        CHECK $DEP_X264
        if [[ $? = 0 ]]; then
            INSTALL $DEP_X264
            return
        fi
    fi


    REMOVE $DEP_X264
    git clone https://code.videolan.org/videolan/x264.git
    cd x264 || { echo "Failed to cd x264"; exit 1; }
    ./configure --prefix=$PREFIX --disable-static --enable-shared --enable-pic
    checkForError
    make -j"$JOBS"
    checkForError
    make install
    checkForError
    ldconfig
    cd ~ || { echo "Failed to cd ~"; exit 1; }
}

# Install Libx265
installLibx265() {
    cd ~ || { echo "Failed to cd ~"; exit 1; }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Building/Installing libx265              |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    if [[ $FORCE_BUILD = false ]]; then
        CHECK $DEP_X265
        if [[ $? = 0 ]]; then
            INSTALL $DEP_X265
            return
        fi
    fi


    REMOVE $DEP_X265
    git clone https://bitbucket.org/multicoreware/x265_git.git
    cd x265_git/build/linux || { echo "Failed to cd x265_git/build/linux"; exit 1; }
    cmake -G "Unix Makefiles" -DLIB_INSTALL_DIR="$PREFIX/lib" -DENABLE_SHARED=on -DENABLE_PIC=on ../../source
    checkForError
    make -j"$JOBS"
    checkForError
    make install
    checkForError
    ldconfig
    cd ~ || { echo "Failed to cd ~"; exit 1; }
}

# Install Libfdk
installLibfdk() {
    cd ~ || { echo "Failed to cd ~"; exit 1; }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |            Building/Installing libfdk-aac             |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    if [[ $FORCE_BUILD = false ]]; then
        CHECK $DEP_AAC
        if [[ $? = 0 ]]; then
            INSTALL $DEP_AAC
            return
        fi
    fi

    REMOVE $DEP_AAC
    git clone https://github.com/mstorsjo/fdk-aac.git
    cd fdk-aac || { echo "Failed to cd fdk-aac"; exit 1; }
    ./autogen.sh
    ./configure --prefix=$PREFIX --disable-static --enable-shared --enable-pic
    checkForError
    make -j"$JOBS"
    checkForError
    make install
    checkForError
    ldconfig
    cd ~ || { echo "Failed to cd ~"; exit 1; }
}

# Install VPX
installLibvpx() {
    cd ~ || { echo "Failed to cd ~"; exit 1; }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |            Building/Installing libvpx-dev             |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    if [[ $FORCE_BUILD = false ]]; then
        CHECK $DEP_VPX
        if [[ $? = 0 ]]; then
            INSTALL $DEP_VPX
            return
        fi
    fi

    REMOVE $DEP_VPX
    git clone https://chromium.googlesource.com/webm/libvpx.git
    cd libvpx || { echo "Failed to cd libvpx"; exit 1; }
    ./autogen.sh
    ./configure --prefix=$PREFIX --disable-static --enable-shared --enable-pic --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
    checkForError
    make -j"$JOBS"
    checkForError
    make install
    checkForError
    ldconfig
    cd ~ || { echo "Failed to cd ~"; exit 1; }
}

# Install VPX
installLibopus() {
    cd ~ || { echo "Failed to cd ~"; exit 1; }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |            Building/Installing libopus-dev            |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    if [[ $FORCE_BUILD = false ]]; then
        CHECK $DEP_OPUS
        if [[ $? = 0 ]]; then
            INSTALL $DEP_OPUS
            return
        fi
    fi

    REMOVE $DEP_OPUS
    git clone https://github.com/xiph/opus.git
    cd opus || { echo "Failed to cd opus"; exit 1; }
    ./autogen.sh
    ./configure --prefix=$PREFIX --disable-static --enable-shared --enable-pic
    checkForError
    make -j"$JOBS"
    checkForError
    make install
    checkForError
    ldconfig
    cd ~ || { echo "Failed to cd ~"; exit 1; }
}

# Install FFmpeg
installFFmpeg() {
    cd ~ || { echo "Failed to cd ~"; exit 1; }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Building/Installing FFmpeg               |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    REMOVE ffmpeg
    wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
    echo "Extracting source code..."
    tar xjf ffmpeg-snapshot.tar.bz2
    cd ffmpeg || { echo "Failed to cd ffmpeg"; exit 1; }

    CMD="--prefix=$PREFIX --enable-nonfree --enable-gpl --disable-ffprobe --disable-ffplay --enable-pic --disable-static --enable-shared"

    if [[ "$FDK" = "y" ]]; then
        CMD="$CMD --enable-libfdk-aac"
    fi

    if [[ "$L264" = "y" ]]; then
        CMD="$CMD --enable-libx264"
    fi

    if [[ "$L265" = "y" ]]; then
        CMD="$CMD --enable-libx265"
    fi

    if [[ "$LVPX" = "y" ]]; then
        CMD="$CMD --enable-libvpx"
    fi

    if [[ "$LOPUS" = "y" ]]; then
        CMD="$CMD --enable-libopus"
    fi

    if [[ "$FLAGSYN" = "y" ]]; then
        CMD="$CMD $FLAGS"
    fi

    ./configure "$CMD" --extra-libs="-lpthread -lm"
    checkForError
    make -j"$JOBS"
    checkForError
    make install
    checkForError
    ldconfig
    cd ~ || { echo "Failed to cd ~"; exit 1; }
}

# Clear Up
cleanDirectory() {
    rm -rf ffmpeg
    rm -rf fdk-aac
    rm -rf x264
    rm -rf x265_git
    rm -rf libvpx
    rm -rf opus
    rm -f ffmpeg-snapshot.tar.bz2
}

# Ask for Threads
getJobsCount() {

    if [[ $JOBS_PARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    printf "   ${Yellow}How many simultaneous jobs would you like to use for build processes (if needed) Default: %s (#):${End}" "$JOBS"
    read -r
    if [[ $REPLY -gt 0 ]]; then
        JOBS=$REPLY
    fi
}

# getLib L264_PARAM L264 "libx264"
getLib(){


    if [[ ${!1} = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    printf "   ${Yellow}Would you like to enable '%s'? Default: %s (y/n):${End}" "$3" "${!2}"
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        eval "$2"="$REPLY"
    fi

}

# Get Compile Flags
getFlags() {

    if [[ $FLAGS_PARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}Would you like to add any extra FFmpeg compile flags? Default: $FLAGSYN (y/n)"
    echo
    echo "   ADVANCED: ${End}Compile flags could be added to the build process, to ensure ffmpeg is compiled with more features."
    printf "   You are responsible for ensuring any required dev/header files are installed: "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        FLAGSYN="$REPLY"
        if [[ "$FLAGSYN" = "y" ]]; then
            echo
            echo "   ${Yellow}Please enter your compile flags below, separated by a space${End}"
            echo
            printf "   Example: --enable-vaapi --enable-libvorbis : "
            read -r
            if [[ ${#REPLY} -gt 0 ]]; then
                FLAGS="$REPLY"
            else
                FLAGSYN="n"
            fi

        fi
    fi

}

# Performance Stop Watch
stopWatch() {
    if [[ "$1" = "stop" ]]; then
        endEpoch=$(date +%s)
        endTime=$(date)
        durationEpoch=$((endEpoch - startEpoch))
        echo
        echo "   Start time: ${startTime}"
        echo "   End time:   ${endTime}"
        echo "   Duration:   ${durationEpoch} seconds"
        echo "   Max jobs:   $JOBS"
        echo "   Option:     $MODE"
        echo
    else
        startEpoch=$(date +%s)
        startTime=$(date)
    fi
}

# Command Processor
processOptions() {

    case $1 in

    1)
        stopWatch "start"
        installDependencies
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;

    2)
        getJobsCount
        stopWatch "start"
        installLibfdk
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;

    3)
        getJobsCount
        stopWatch "start"
        installLibx264
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;
    4)
        getJobsCount
        stopWatch "start"
        installLibx265
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;

    5)
        getJobsCount
        stopWatch "start"
        installLibvpx
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;

    6)
        getJobsCount
        stopWatch "start"
        installLibopus
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;

    7)
        getJobsCount
        stopWatch "start"
        installFFmpeg
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;

    8)
        getJobsCount
        getLib FDK_PARAM FDK "libfdk-aac"
        getLib L264_PARAM L264 "libx264"
        getLib L265_PARAM L265 "libx265"
        getLib LVPX_PARAM LVPX "libvpx"
        getLib LOPUS_PARAM LOPUS "libopus"
        getFlags
        stopWatch "start"
        installDependencies
        if [[ "$FDK" = "y" ]]; then
            installLibfdk
        fi
        if [[ "$L264" = "y" ]]; then
            installLibx264
        fi
        if [[ "$L265" = "y" ]]; then
            installLibx265
        fi
        if [[ "$LVPX" = "y" ]]; then
            installLibvpx
        fi
        if [[ "$LOPUS" = "y" ]]; then
            installLibopus
        fi
        installFFmpeg
        cleanDirectory
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;

    9)
        stopWatch "start"
        cleanDirectory
        stopWatch "stop"
        if [ "$INTERACTIVE" = "y" ]; then
            echo "   ${Yellow}All Done!${End} ...press enter"
            read -r
            printHeader
            menu
        fi
        ;;
    esac
}

# Entry Point
cd ~ || { echo "Failed to cd ~"; exit 1; }

while [ $# -gt 0 ]; do

    case "$1" in

    --help)
        printf "\033c"
        echo "Options:"
        echo
        echo " --force-build                                  : Forces the build of required libs, regardless of their availability with the systems repository sources"
        echo " --none-interactive                             : Disables interactive mode"
        echo " --mode               [1-9]                     : Sets the operation. Requires --none-interactive"
        echo " --max-jobs           [1-#] Default: 3          : Sets the number of build threads"
        echo " --libfdk-aac         [y:n] Default: y          : Enable/Disable this lib"
        echo " --libx264            [y:n] Default: y          : Enable/Disable this lib"
        echo " --libx265            [y:n] Default: n          : Enable/Disable this lib"
        echo " --libopus            [y:n] Default: n          : Enable/Disable this lib"
        echo " --libvpx             [y:n] Default: n          : Enable/Disable this lib"
        echo " --extra-flags        [*]   Default: None       : Adds extra build args to the ffmpeg build"
        echo " --path               [*]   Default: /usr/local : Set custom install path"
        echo
        exit 0
        ;;
    --force-build)
        FORCE_BUILD=true
        ;;
    --none-interactive)
        INTERACTIVE="n"
        ;;
    --mode)
        MODE=$2
        MODE_PARAM=true
        ;;
    --max-jobs)
        JOBS=$2
        JOBS_PARAM=true
        ;;
    --libfdk-aac)
        FDK="$2"
        FDK_PARAM=true
        ;;
    --libx264)
        L264="$2"
        L264_PARAM=true
        ;;
    --libx265)
        L265="$2"
        L265_PARAM=true
        ;;
    --libopus)
        LOPUS="$2"
        LOPUS_PARAM=true
        ;;
    --libvpx)
        LVPX="$2"
        LVPX_PARAM=true
        ;;
    --extra-flags)
        FLAGSYN="y"
        FLAGS="$2"
        FLAGS_PARAM=true
        ;;
    --path)
        PREFIX="$2"
        export LDFLAGS="-L$PREFIX/lib"
        export CFLAGS="-I$PREFIX/include"
        ;;
    esac
    shift
done

if [ "$INTERACTIVE" = "n" ]; then
    printHeader
    processOptions "$MODE"

else
    printHeader
    menu
fi
