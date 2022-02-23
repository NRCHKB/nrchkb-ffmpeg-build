#!/bin/bash

# nrchkb-ffmpeg-build Version 1.0

# MIT License

# Copyright (c) 2022 Marcus Davies
# Copyright (c) 2022 Garrett Porter

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
JOBSPARAM=false  # Arg provided
OMX="n"          # OMX Choice Value
OMXPARAM=false   # Arg provided
FDK="y"          # FDK Choice Value
FDKPARAM=false   # Arg provided
FLAGSYN="n"      # Flags Choice Value
FLAGS=""         # Flasg Value
FLAGSPARAM=false # Arg provided
MODE=0           # Mode Value
MODEPARAM=false  # Arg provided

INTERACTIVE="y" # Interactive

# Print Header
printHeader() {

    printf "\033c"
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                   1.0 |"
    echo " |          P&M FFmpeg Build Script (Debian)             |"
    echo " |   An FFmpeg build & installation utility for NRCHKB   |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    echo " ${Red}Note: This script will install into /usr/bin and /usr/lib respectively.${End}"
    echo

}

# Print menu
menu() {

    echo " ${Yellow}What would you like to do:${End}"
    echo
    echo "   1 - Install build tools (dependencies from apt)"
    echo "   2 - Build/install libfdk-aac (AAC encoder, needed for HomeKit audio)"
    echo "   3 - Build/install FFmpeg (video processor, builds from source)"
    echo "   4 - All of the above"
    echo "   5 - Cleanup build directories"
    echo "   q - Quit"
    echo
    echo "   Note: this script will download and compile these software packages from source code."
    echo "   This will take a long time. Option 4 will take over 6 hours on a Pi Zero W."
    echo
    echo "   If you have previously run this script, running it again will update your software."
    echo
    printf "   Choice: "
    read -r
    if [[ "$REPLY" = "q" ]]; then
        exit 0
    fi

    MODE=$REPLY

    if [[ $MODE -gt 5 || $MODE -lt 1 ]]; then
        printHeader
        menu
    fi
    processOptions $MODE
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
    sudo apt install -y pkg-config autoconf automake libtool git wget make g++ gcc nasm yasm

    sudo apt info libx264-dev

    if [[ $? -gt 0 ]]; then
        installLibx264
    else
        sudo apt install -y libx264-dev
    fi

}

# Install Libx264
installLibx264() {
    cd ~ || {
        echo "cd failed, aborting at installLibx264:01"
        exit 1
    }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Building/Installing libx264              |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    sudo apt remove -y libx264-dev
    sudo apt purge -y libx264-dev
    git clone https://code.videolan.org/videolan/x264.git
    cd x264 || {
        echo "cd failed, aborting at installLibx264:02"
        exit 1
    }
    sudo ./configure --prefix="/usr" --enable-static --enable-pic
    checkForError
    sudo make -j"$JOBS"
    checkForError
    sudo make install
    checkForError
    sudo ldconfig
    cd ~ || {
        echo "cd failed, aborting at installLibx264:03"
        exit 1
    }
}

# Install Libfdk
installLibfdk() {
    cd ~ || {
        echo "cd failed, aborting at installLibfdk:01"
        exit 1
    }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |            Building/Installing libfdk-aac             |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    sudo apt remove -y libfdk-aac-dev
    sudo apt purge -y libfdk-aac-dev
    git clone https://github.com/mstorsjo/fdk-aac.git
    cd fdk-aac || {
        echo "cd failed, aborting at installLibfdk:02"
        exit 1
    }
    sudo ./autogen.sh
    sudo ./configure --prefix="/usr" --enable-static --disable-shared
    checkForError
    sudo make -j"$JOBS"
    checkForError
    sudo make install
    checkForError
    sudo ldconfig
    cd ~ || {
        echo "cd failed, aborting at installLibfdk:03"
        exit 1
    }
}

# Install FFmpeg
installFFmpeg() {
    cd ~ || {
        echo "cd failed, aborting at installFFmpeg:01"
        exit 1
    }
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Building/Installing FFmpeg               |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    sudo apt remove -y ffmpeg
    sudo apt purge -y ffmpeg
    wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
    echo "Extracting source code..."
    tar xjf ffmpeg-snapshot.tar.bz2
    cd ffmpeg || {
        echo "cd failed, aborting at installFFmpeg:02"
        exit 1
    }

    CMD="--prefix=\"/usr\" --enable-nonfree --enable-gpl --enable-hardcoded-tables --disable-ffprobe --disable-ffplay --enable-libx264"

    if [[ "$FDK" = "y" ]]; then
        CMD="$CMD --enable-libfdk-aac"
    fi

    if [[ "$OMX" = "y" ]]; then
        CMD="$CMD --enable-mmal"
        CMD="$CMD --enable-omx"
        CMD="$CMD --enable-omx-rpi"
    fi

    if [[ "$FLAGSYN" = "y" ]]; then
        CMD="$CMD $FLAGS"
    fi

    sudo ./configure $CMD
    checkForError
    sudo make -j"$JOBS"
    checkForError
    sudo make install
    checkForError
    cd ~ || {
        echo "cd failed, aborting at installFFmpeg:03"
        exit 1
    }
}

# Clear Up
cleanDirectory() {
    sudo rm -rf ffmpeg
    sudo rm -rf fdk-aac
    sudo rm -rf x264
    sudo rm -f ffmpeg-snapshot.tar.bz2
}

# Ask for Threads
getJobsCount() {

    if [[ $JOBSPARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}How many simultaneous jobs would you like to use for build processes (if needed)${End}"
    echo
    echo "   The more you specify - the higher chance of CPU throttling and memory constraints"
    printf "   we recommend no more than 3 for a Pi 4 (1-4): "
    read -r
    if [[ $REPLY -lt 5 && $REPLY -gt 0 ]]; then
        JOBS=$REPLY
    fi
}

# Ask for omx
getOMX() {

    if [[ $OMXPARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}Would you like to enable 'h264_omx'?${End}"
    echo
    echo "   Note: 'h264_omx' is deprecated and should not be used on new installs."
    printf "   If you already use it, choose yes here. Enter (y/n): "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        OMX="$REPLY"
    fi
}

# Ask for FDK
getFDK() {

    if [[ $FDKPARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}Would you like to enable 'libfdk-aac'?${End}"
    echo
    echo "   Note: 'libfdk-aac' is needed for HomeKit audio. We recommend enabling libfdk-aac."
    printf "   If you are running Option 4, you can enable this lib. Enter (y/n): "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        FDK="$REPLY"
    fi
}

# Get Compile Flags
getFlags() {

    if [[ $FLAGSPARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}Would you like to add any extra FFmpeg compile flags?"
    echo
    echo "   ADVANCED: ${End}Compile flags could be added to enable libx265 or the countless others"
    printf "   You are responsible for ensuring any required parts are installed (y/n): "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        FLAGSYN="$REPLY"
        if [[ "$FLAGSYN" = "y" ]]; then
            echo
            echo "   ${Yellow}Please enter your compile flags below, separated by a space${End}"
            echo
            printf "   Example '--enable-libx265 --enable-libopus' : "
            read -r
            if [[ "$REPLY" != "" ]]; then
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
        getJobsCount
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
        getOMX
        getFDK
        getFlags
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

    4)
        cleanDirectory
        getJobsCount
        getOMX
        getFDK
        getFlags
        stopWatch "start"
        installDependencies
        if [[ "$FDK" = "y" ]]; then
            installLibfdk
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

    5)
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
cd ~ || {
    echo "cd failed, aborting"
    exit 1
}

while [ $# -gt 0 ]; do

    case "$1" in

    --help | -h)
        echo "Options:"
        echo
        echo " --interactive -i    [y|n]             Default: y        Disables interactive mode"
        echo " --mode        -m    [1|2|3|4|5]                         Sets the mode (requires --interactive 0, ignored otherwise)"
        echo " --max-jobs    -j    [#]               Default: 3        Set maximum number of builds jobs"
        echo " --libfdk-aac  -a    [y|n]             Default: y        Compile/enable libfdk-aac"
        echo " --h264-omx    -x    [y|n]             Default: n        Enable h264-omx"
        echo " --extra-flags -f    [\"--*-* --*-*\"]   Default: empty    Provides compile flags for ffmpeg"
        echo
        echo " Example: ./build-debian.sh --interactive n --max-jobs 2 --mode 4"
        echo
        exit 0
        ;;
    --interactive | -i)
        INTERACTIVE="$2"
        ;;
    --mode | -m)
        MODE=$2
        MODEPARAM=true
        ;;
    --max-jobs | -j)
        JOBS=$2
        JOBSPARAM=true
        ;;
    --h264-omx | -x)
        OMX="$2"
        OMXPARAM=true
        ;;
    --libfdk-aac | -a)
        FDK="$2"
        FDKPARAM=true
        ;;
    --extra-flags | -f)
        FLAGSYN="y"
        FLAGS="$2"
        FLAGSPARAM=true
        ;;
    esac
    shift
done

if [ "$INTERACTIVE" = "n" ]; then
    processOptions $MODE

else
    printHeader
    menu
fi
