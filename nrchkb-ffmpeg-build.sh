#!/bin/bash

# nrchkb-ffmpeg-build Version 0.7

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

# Print Header
printHeader() {

    printf "\033c"
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |               P&M FFmpeg Build Script                 |"
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
    read Mode

    if [[ "$Mode" = "q" ]]; then
        exit 0
    fi

    if [[ $Mode > 5 || $Mode < 1 ]]; then
        printHeader
        menu
    fi
    processOptions $Mode
}

# Error Check
checkForError() {
    if [[ $? > 0 ]]; then
        echo
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

    LibXCheck=(sudo apt info libx264-dev)

    if [[ $? > 0 ]]; then
        installLibx264
    else
        sudo apt install -y libx264-dev
    fi

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
    sudo apt remove -y libx264-dev
    sudo apt purge -y libx264-dev
    git clone https://code.videolan.org/videolan/x264.git
    cd x264
    sudo ./configure --prefix="/usr" --enable-static --enable-pic
    checkForError
    sudo make -j$Jobs
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
    sudo apt remove -y libfdk-aac-dev
    sudo apt purge -y libfdk-aac-dev
    git clone https://github.com/mstorsjo/fdk-aac.git
    cd fdk-aac
    sudo ./autogen.sh
    sudo ./configure --prefix="/usr" --enable-static --disable-shared
    checkForError
    sudo make -j$Jobs
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
    sudo apt remove -y ffmpeg
    sudo apt purge -y ffmpeg
    wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
    echo "Extracting source code..."
    tar xjf ffmpeg-snapshot.tar.bz2
    cd ffmpeg

    CMD="--prefix=\"/usr\" --enable-nonfree --enable-gpl --enable-hardcoded-tables --disable-ffprobe --disable-ffplay --enable-libx264"

    if [[ "$FDK" != "n" ]]; then
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
    sudo make -j$Jobs
    checkForError
    sudo make install
    checkForError
    cd ~
}

# Clear Up
cleanDirectory() {
    sudo rm -rf ffmpeg
    sudo rm -rf fdk-aac
    sudo rm -rf x264
    sudo rm -f ffmpeg-snapshot.tar.bz2
}

# Ask for Threads
getJobscount() {
    echo
    echo "   ${Yellow}How many simultaneous jobs would you like to use for build processes (if needed)${End}"
    echo
    echo "   The more you specify - the higher chance of CPU throttling and memory constraints"
    printf "   we recommend no more than 3 for a Pi 4 (1-4): "
    read Jobs
    if [[ "$Jobs" != "1" && "$Jobs" != "2" && "$Jobs" != "4" ]]; then
        Jobs=3
    fi
}

# Ask for omx
getOMX() {
    echo
    echo "   ${Yellow}Would you like to enable 'h264_omx'?${End}"
    echo
    echo "   Note: 'h264_omx' is deprecated and should not be used on new installs."
    printf "   If you already use it, choose yes here. Enter (y/n): "
    read OMX
}

# Ask for FDK
getFDK() {
    echo
    echo "   ${Yellow}Would you like to enable 'libfdk-aac'?${End}"
    echo
    echo "   Note: 'libfdk-aac' is needed for HomeKit audio. We recommend enabling libfdk-aac."
    printf "   If you are running Option 4, you can enable this lib. Enter (y/n): "
    read FDK
}

# Get Compile Flags
getFlags() {

    echo
    echo "   ${Yellow}Would you like to add any extra FFmpeg compile flags?"
    echo
    echo "   ADVANCED: ${End}Compile flags could be to enable libx265 or the countless others"
    printf "   You are responsable for ensuring any required parts are installed (y/n): "
    read FLAGSYN

    if [[ "$FLAGSYN" = "y" ]]; then
        echo
        echo "   ${Yellow}Please enter your compile flags below, separated by a space${End}"
        echo
        printf "   Example '--enable-libx265 --enable-libopus' : "
        read FLAGS
    fi

}

# Command Processor
processOptions() {

    case $1 in

    1)
        getJobscount
        startEpoch=$(date +%s)
        startTime=$(date)
        installDependencies
        endEpoch=$(date +%s)
        endTime=$(date)
        durationEpoch=$( expr ${endEpoch} - ${startEpoch} )
        echo
        echo "   Start time: ${startTime}"
        echo "   End time:   ${endTime}"
        echo "   Duration:   ${durationEpoch} seconds"
        echo
        echo "   ${Yellow}All Done!${End} ...press enter"
        read
        printHeader
        menu
        ;;

    2)
        getJobscount
        startEpoch=$(date +%s)
        startTime=$(date)
        installLibfdk
        endEpoch=$(date +%s)
        endTime=$(date)
        durationEpoch=$( expr ${endEpoch} - ${startEpoch} )
        echo
        echo "   Start time: ${startTime}"
        echo "   End time:   ${endTime}"
        echo "   Duration:   ${durationEpoch} seconds"
        echo
        echo "   ${Yellow}All Done!${End} ...press enter"
        read
        printHeader
        menu
        ;;

    3)
        getJobscount
        getOMX
        getFDK
        getFlags
        startEpoch=$(date +%s)
        startTime=$(date)
        installFFmpeg
        endEpoch=$(date +%s)
        endTime=$(date)
        durationEpoch=$( expr ${endEpoch} - ${startEpoch} )
        echo
        echo "   Start time: ${startTime}"
        echo "   End time:   ${endTime}"
        echo "   Duration:   ${durationEpoch} seconds"
        echo
        echo "   ${Yellow}All Done!${End} ...press enter"
        read
        printHeader
        menu
        ;;

    4)
        cleanDirectory
        getJobscount
        getOMX
        getFDK
        getFlags
        startEpoch=$(date +%s)
        startTime=$(date)
        installDependencies
        if [[ "$FDK" != "n" ]]; then
            installLibfdk
        fi
        installFFmpeg
        cleanDirectory
        endEpoch=$(date +%s)
        endTime=$(date)
        durationEpoch=$( expr ${endEpoch} - ${startEpoch} )
        echo
        echo "   Start time: ${startTime}"
        echo "   End time:   ${endTime}"
        echo "   Duration:   ${durationEpoch} seconds"
        echo
        echo "   ${Yellow}All Done!${End} ...press enter"
        read
        printHeader
        menu
        ;;

    5)
        startEpoch=$(date +%s)
        startTime=$(date)
        cleanDirectory
        endEpoch=$(date +%s)
        endTime=$(date)
        durationEpoch=$( expr ${endEpoch} - ${startEpoch} )
        echo
        echo "   Start time: ${startTime}"
        echo "   End time:   ${endTime}"
        echo "   Duration:   ${durationEpoch} seconds"
        echo
        echo "   ${Yellow}All Done!${End} ...press enter"
        read
        printHeader
        menu
        ;;
    esac
}

# Entry Point
cd ~
printHeader
menu
