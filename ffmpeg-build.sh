#!/bin/bash

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
    echo " |               P&M FFMPEG Build Script                 |"
    echo " |   An FFMPEG build & installation utility for NRCHKB   |"
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
    echo "   1 - Install build tools (We need stuff todo stuff)"
    echo "   2 - Build/install libfdk-aac (AAC Encoder with AAC-ELD)"
    echo "   3 - Build/install FFMPEG (The party piece)"
    echo "   4 - All of the above"
    echo "   5 - Build/install libx264 (Only needed if libx264-dev is not available)"
    echo "   6 - Cleanup build directories"
    echo "   q - Quit"
    echo
    printf "   Choice: "
    read Mode

    if [[ "$Mode" = "q" ]]; then
        exit 0
    fi

    if [[ $Mode > 6 || $Mode < 1 ]]; then
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
    sudo apt install -y pkg-config autoconf automake libtool git wget libx264-dev
}

# Install Libx264
installLibx264() {
    cd ~
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Installing/Building libx264              |"
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
    echo " |            Installing/Building libfdk-aac             |"
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

# Install FFMPEG
installFFmpeg() {
    cd ~
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |              Installing/Building ffmpeg               |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
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
    echo "   ${Yellow}How many simultaneous jobs would you like to use for the build process (1-4)"
    printf "   Note: The more you specify - the higher chance of CPU throttling and memory constraints - we recommend no more than 3 for a Pi4 with 4GB :${End} "
    read Jobs
}

# Ask for omx
getOMX() {
    echo
    echo "   ${Yellow}Would you like to enable 'h264_omx' (y/n)"
    printf "   Note: We recommend using 'h264_v4l2m2m', as 'h264_omx' is problematic on newer OS's and 64Bit systesms:${End} "
    read OMX
}

# Ask for FDK
getFDK() {
    echo
    echo "   ${Yellow}Would you like to enable 'libfdk-aac' (y/n)"
    echo "   Note: You will need to have built or install libfdk-aac-dev from your OS's repository"
    printf "         If you chose option 4 - you can enable this lib:${End} "
    read FDK
}

# Command Processor
processOptions() {

    case $1 in

    1)
        installDependencies
        echo
        echo "   ${Yellow}All Done!${End}"
        read
        printHeader
        menu
        ;;

    2)
        cleanDirectory
        getJobscount
        installLibfdk
        cleanDirectory
        echo
        echo "   ${Yellow}All Done!${End}"
        read
        printHeader
        menu
        ;;

    3)
        cleanDirectory
        getJobscount
        getOMX
        getFDK
        installFFmpeg
        cleanDirectory
        echo
        echo "   ${Yellow}All Done!${End}"
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
        installLibfdk
        installFFmpeg
        cleanDirectory
        echo
        echo "   ${Yellow}All Done!${End}"
        read
        printHeader
        menu
        ;;

    5)
        cleanDirectory
        getJobscount
        installLibx264
        cleanDirectory
        echo
        echo "   ${Yellow}All Done!${End}"
        read
        printHeader
        menu
        ;;

    6)
        cleanDirectory
        echo
        echo "   ${Yellow}All Done!${End}"
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
