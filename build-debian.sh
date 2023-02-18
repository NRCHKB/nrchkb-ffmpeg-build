#!/bin/bash

# nrchkb-ffmpeg-build Version 2.0

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
FDK="y"          # FDK Choice Value
FDKPARAM=false   # Arg provided
L264="y"         # 264 Choice Value
L264ARAM=false   # Arg provided
L265="y"         # 265 Choice Value
L265ARAM=false   # Arg provided
FLAGSYN="n"      # Flags Choice Value
FLAGS=""         # Flasg Value
FLAGSPARAM=false # Arg provided
MODE=0           # Mode Value
MODEPARAM=false  # Arg provided
INTERACTIVE="y"  # Interactive

# Prefix
PREFIX="/usr/local"
export LDFLAGS="-L$PREFIX/lib"
export CFLAGS="-I$PREFIX/include"

# Specific package manager implemention
INSTALL() {
    sudo apt install -y $@
}
REMOVE() {
    sudo apt remove -y $1
    sudo apt purge -y $1
}
CHECK() {
    apt info $1
}

# Package Names
DEPX264="libx264-dev"
DEPX265="libx265-dev"
DEPAAC="libfdk-aac-dev"

# Print Header
printHeader() {

    printf "\033c"
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                   2.0 |"
    echo " |          P&M FFmpeg Build Script (Debian)             |"
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
    echo "   5 - Build FFmpeg (Biulds from source only)"
    echo "   6 - All of the above"
    echo "   7 - Purge build directories"
    echo "   q - Quit"
    echo
    echo "   Note: This script will download and compile these software packages from source code,"
    echo "         unless they happen to be available from your systems repository."
    echo "         Where necessary, libaries will be built as shared libs."
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
    INSTALL pkg-config autoconf automake libtool git wget make g++ gcc nasm yasm build-essential cmake-curses-gui cmake

}

# Install Libx264
installLibx264() {
    cd ~
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Building/Installing libx264              |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    CHECK $DEPX264
    if [[ $? = 0 ]]; then
        INSTALL $DEPX264
        return
    fi


    REMOVE $DEPX264
    git clone https://code.videolan.org/videolan/x264.git
    cd x264
    ./configure --prefix=$PREFIX --disable-static --enable-shared --enable-pic
    checkForError
    make -j"$JOBS"
    checkForError
    sudo make install
    checkForError
    sudo ldconfig
    cd ~
}

# Install Libx265
installLibx265() {
    cd ~
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Building/Installing libx265              |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    CHECK $DEPX265
    if [[ $? = 0 ]]; then
        INSTALL $DEPX265
        return
    fi


    REMOVE $DEPX265
    git clone https://bitbucket.org/multicoreware/x265_git.git
    cd x265
    ./configure --prefix=$PREFIX --disable-static --enable-shared --enable-pic
    checkForError
    make -j"$JOBS"
    checkForError
    sudo make install
    checkForError
    sudo ldconfig
    cd ~
}

# Install Libfdk
installLibfdk() {
    cd ~
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |            Building/Installing libfdk-aac             |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo

    CHECK $DEPAAC
    if [[ $? = 0 ]]; then
        INSTALL $DEPAAC
        return
    fi

    REMOVE $DEPAAC
    git clone https://github.com/mstorsjo/fdk-aac.git
    cd fdk-aac
    ./autogen.sh
    ./configure --prefix=$PREFIX --disable-static --enable-shared --enable-pic
    checkForError
    make -j"$JOBS"
    checkForError
    sudo make install
    checkForError
    sudo ldconfig
    cd ~
}

# Install FFmpeg
installFFmpeg() {
    cd ~
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
    cd ffmpeg

    CMD="--prefix=$PREFIX --enable-nonfree --enable-gpl --enable-hardcoded-tables --disable-ffprobe --disable-ffplay --enable-pic --disable-static --enable-shared --extra-libs='-lpthread -lm'"

    if [[ "$FDK" = "y" ]]; then
        CMD="$CMD --enable-libfdk-aac"
    fi

    if [[ "$L264" = "y" ]]; then
        CMD="$CMD --enable-libx264"
    fi

    if [[ "$L265" = "y" ]]; then
        CMD="$CMD --enable-libx265"
    fi

    if [[ "$FLAGSYN" = "y" ]]; then
        CMD="$CMD $FLAGS"
    fi

    ./configure $CMD
    checkForError
    make -j"$JOBS"
    checkForError
    sudo make install
    checkForError
    cd ~
}

# Clear Up
cleanDirectory() {
    rm -rf ffmpeg
    rm -rf fdk-aac
    rm -rf x264
    rm -rf x265
    rm -f ffmpeg-snapshot.tar.bz2
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

# Ask for FDK
getFDK() {

    if [[ $FDKPARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}Would you like to enable 'libfdk-aac'?${End}"
    echo
    echo "   Note: 'libfdk-aac' is needed for HomeKit audio. We recommend enabling libfdk-aac."
    printf "   If you are running Option 5, you can enable this lib. Enter (y/n): "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        FDK="$REPLY"
    fi
}

# Ask for X264
getX624() {

    if [[ $L264ARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}Would you like to enable 'libx264'?${End}"
    echo
    echo "   Note: 'libx264' is needed for HomeKit video, as that is the only codc is will support."
    printf "   If you are running Option 5, you can enable this lib. Enter (y/n): "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        L264="$REPLY"
    fi
}

# Ask for X265
getX625() {

    if [[ $L265ARAM = true || "$INTERACTIVE" = "n" ]]; then
        return
    fi

    echo
    echo "   ${Yellow}Would you like to enable 'libx265'?${End}"
    echo
    echo "   Whilst not strictly requied, will add support never the less."
    printf "   If you are running Option 5, you can enable this lib. Enter (y/n): "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        L265="$REPLY"
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
    echo "   ADVANCED: ${End}Compile flags could be added to the build process, to ensure ffmpeg is compiled with more features."
    printf "   You are responsible for ensuring any requied dev/header files are installed (y/n): "
    read -r
    if [[ "$REPLY" = "y" || "$REPLY" = "n" ]]; then
        FLAGSYN="$REPLY"
        if [[ "$FLAGSYN" = "y" ]]; then
            echo
            echo "   ${Yellow}Please enter your compile flags below, separated by a space${End}"
            echo
            printf "   Example '--enable-vaapi --enable-libopus' : "
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
        installFFmpeg
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
        getFDK
        getX624
        getX625
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

    7)
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
        echo " --mode        -m    [1|2|3|4|5|6|7]                     Sets the mode (requires --interactive 0, ignored otherwise)"
        echo " --max-jobs    -j    [#]               Default: 3        Set maximum number of builds jobs"
        echo " --libfdk-aac  -a    [y|n]             Default: y        Compile/enable libfdk-aac"
        echo " --libx264     -4    [y|n]             Default: y        Compile/enable libx264"
        echo " --libx265     -5    [y|n]             Default: y        Compile/enable libx265"
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
    --libfdk-aac | -a)
        FDK="$2"
        FDKPARAM=true
        ;;
    --libx264 | -4)
        L264="$2"
        L264ARAM=true
        ;;
    --libx265 | -5)
        L265="$2"
        L265ARAM=true
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
    printHeader
    processOptions $MODE

else
    printHeader
    menu
fi
