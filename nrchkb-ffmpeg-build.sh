#!/bin/bash

# Version 0.3
# By Marcus and Porter

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
    sudo apt install -y pkg-config autoconf automake libtool git wget

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
    wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
    echo "Extracting source code..."
    tar xjf ffmpeg-snapshot.tar.bz2
    cd ffmpeg

    CMD="--prefix=\"/usr\" --enable-nonfree --enable-gpl --enable-hardcoded-tables --disable-ffprobe --disable-ffplay --enable-libx264"

    if [[ "$FDK" = "y" ]]; then
        CMD="$CMD --enable-libfdk-aac"
    fi

    if [[ "$OMX" = "y" ]]; then
        CMD="$CMD --enable-mmal"
        CMD="$CMD --enable-omx"
        CMD="$CMD --enable-omx-rpi"
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
}

# Ask for Threads
getJobscount() {
    echo
    echo "   ${Yellow}How many simultaneous jobs would you like to use for build processes (if needed)${End}"
    echo
    echo "   The more you specify - the higher chance of CPU throttling and memory constraints"
    printf "   we recommend no more than 3 for a Pi 4 (1-4): "
    read Jobs
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

# Command Processor
processOptions() {

    case $1 in

    1)
        getJobscount
        installDependencies
        echo
        echo "   ${Yellow}All Done!${End} ...press enter"
        read
        printHeader
        menu
        ;;

    2)
        getJobscount
        installLibfdk
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
        installFFmpeg
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
        installDependencies
        if [[ "$FDK" = "y" ]]; then
            installLibfdk
        fi
        installFFmpeg
        cleanDirectory
        echo
        echo "   ${Yellow}All Done!${End} ...press enter"
        read
        printHeader
        menu
        ;;

    5)
        cleanDirectory
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
