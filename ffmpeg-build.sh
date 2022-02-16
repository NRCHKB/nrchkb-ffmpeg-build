#!/bin/bash

# Colors
Red=$'\e[0;31m'
Yellow=$'\e[1;33m'
End=$'\e[0m'

# Print Header
printHeader(){
    
    printf "\033c"
    echo
    echo " ---------------------------------------------------------"
    echo " |                                                       |"
    echo " |               P&M FFMPEG Build Script                 |"
    echo " |     An FFMPEG build & installation utility NRCHKB     |"
    echo " |                                                       |"
    echo " ---------------------------------------------------------"
    echo
    
    printf " ${Red}Note: This script will install into /usr/bin and /usr/lib respectively.${End}\r\n"
    echo
    
}

# Print menu
menu(){
    
    printf " ${Yellow}What would you like to do:${End}\r\n"
    echo
    echo "   1 - Install Build Tools (We need stuff todo stuff)"
    echo "   2 - Build/install libfdk_aac (AAC Encoder with AAC-ELD)"
   #echo "   3 - Build/install libx264 (Software Renderer)"
    echo "   3 - Build/install FFMPEG (The party piece)"
    echo "   4 - All of the above"
    echo "   5 - Delete build directories"
    echo
    printf "   Choice: "
    read Mode
    if [[ $Mode -gt 5 || $Mode -lt 1 ]]
    then
        printHeader
        menu
    fi
    processOptions $Mode
}

# Error Check
checkForError(){
    if [[ $? > 0 ]]
    then
        echo
        printf "${Red}"
        printf " ---------------------------------------------------------"
        printf " |                                                       |"
        printf " |                   Error occurred                      |"
        printf " |        Please check the logs and try again            |"
        printf " |                                                       |"
        printf " ---------------------------------------------------------"
        printf "${End}"
        echo
        exit 1
    fi
}

# Install Dependencies
installDependencies(){
    echo
    sudo apt install -y pkg-config autoconf automake libtool git libx264-dev
}

# Install Libx264
installLibx264(){
    cd ~
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
installLibfdk(){
    cd ~
    echo
    git clone https://github.com/mstorsjo/fdk-aac.git
    cd fdk-aac
    sudo ./autogen.sh
    sudo ./configure --prefix="/usr" --enable-static  --disable-shared
    checkForError
    sudo make -j$Jobs
    checkForError
    sudo make install
    checkForError
    sudo ldconfig
    cd ~
}

# Install FFMPEG
installFFmpeg(){

    cd ~
    echo
    git clone https://github.com/FFmpeg/FFmpeg.git
    cd FFmpeg
    
    CMD="--prefix=\"/usr\" --enable-nonfree --enable-gpl --enable-hardcoded-tables --disable-ffprobe --disable-ffplay"
    
    if [[ "$FDK" = "y" ]]
    then
        CMD="$CMD --enable-libfdk-aac"
    fi
    
    if [[ "$X264" = "y" ]]
    then
        CMD="$CMD --enable-libx264"
    fi
    
    if [[ "$OMX" = "y" ]]
    then
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
cleanDirectory(){
    sudo rm -rf FFmpeg
    sudo rm -rf fdk-aac
    sudo rm -rf x264
}

# Ask for Threads
getJobscount(){
    echo
    printf "   ${Yellow}How many simultaneous jobs would you like to use for the build process (1-4)\r\n"
    printf "   Note: The more you specify - the higher chance of CPU throttling and memory constraints - we recommend no more than 3 for a Pi4 with 4GB :${End} "
    read Jobs
}

# Ask for omx
getOMX(){
    echo
    printf "   ${Yellow}Would you like to enable 'h264_omx' (y/n)\r\n"
    printf "   Note: We recommend using 'h264_v4l2m2m', as 'h264_omx' is problematic on newer OS's and 64Bit systesms:${End} "
    read OMX
}

# Ask for X264
getX264(){
    echo
    printf "   ${Yellow}Would you like to enable 'libx264' (y/n)\r\n"
    printf "   Note: You will need to have built or install libx264-dev from your OS's repository\r\n"
    printf "         If you chose option 5 - you can enable this lib:${End} "
    read X264
}

# Ask for FDK
getFDK(){
    echo
    printf "   ${Yellow}Would you like to enable 'libfdk-aac' (y/n)\r\n"
    printf "   Note: You will need to have built or install libfdk-aac-dev from your OS's repository\r\n"
    printf "         If you chose option 5 - you can enable this lib:${End} "
    read FDK
}

# Command Processor
processOptions(){
    
    case $1 in
        
        1)
            echo
            echo " ---------------------------------------------------------"
            echo " |                                                       |"
            echo " |               Installing Dependencies                 |"
            echo " |                                                       |"
            echo " ---------------------------------------------------------"
            echo
            installDependencies
            echo
            printf "   ${Yellow}All Done!${End}\r\n"
            read
            printHeader
            menu
        ;;
        
        2)
            cleanDirectory
            getJobscount
            echo
            echo " ---------------------------------------------------------"
            echo " |                                                       |"
            echo " |            Installing/Building Libfdk-aac             |"
            echo " |                                                       |"
            echo " ---------------------------------------------------------"
            echo
            installLibfdk
            echo
            printf "   ${Yellow}All Done!${End}\r\n"
            read
            printHeader
            menu
        ;;
        
        #3)
        #    cleanDirectory
        #    getJobscount
        #    echo
        #    echo " ---------------------------------------------------------"
        #    echo " |                                                       |"
        #    echo " |              Installing/Building libx264              |"
        #    echo " |                                                       |"
        #    echo " ---------------------------------------------------------"
        #    echo
        #    installLibx264
        #    echo
        #    printf "   ${Yellow}All Done!${End}\r\n"
        #    read
        #    printHeader
        #    menu
        #;;
        
        3)
            cleanDirectory
            getJobscount
            getOMX
            #getX264
            getFDK
            echo
            echo " ---------------------------------------------------------"
            echo " |                                                       |"
            echo " |              Installing/Building ffmpeg               |"
            echo " |                                                       |"
            echo " ---------------------------------------------------------"
            echo
            installFFmpeg
            echo
            printf "   ${Yellow}All Done!${End}\r\n"
            read
            printHeader
            menu
        ;;
        
        4)
            cleanDirectory
            getJobscount
            getOMX
            #getX264
            getFDK
            echo
            echo " ---------------------------------------------------------"
            echo " |                                                       |"
            echo " |               Installing Dependencies                 |"
            echo " |                                                       |"
            echo " ---------------------------------------------------------"
            echo
            installDependencies
            echo
            echo " ---------------------------------------------------------"
            echo " |                                                       |"
            echo " |            Installing/Building Libfdk-aac             |"
            echo " |                                                       |"
            echo " ---------------------------------------------------------"
            echo
            installLibfdk
           #echo
           #echo " ---------------------------------------------------------"
           #echo " |                                                       |"
           #echo " |              Installing/Building libx264              |"
           #echo " |                                                       |"
           #echo " ---------------------------------------------------------"
           #echo
           #installLibx264
            echo
            echo " ---------------------------------------------------------"
            echo " |                                                       |"
            echo " |             Installing/Building ffmpeg                |"
            echo " |                                                       |"
            echo " ---------------------------------------------------------"
            echo
            installFFmpeg
            echo
            printf "   ${Yellow}All Done!${End}\r\n"
            read
            printHeader
            menu
        ;; 
        
        5)
            cleanDirectory
            echo
            printf "   ${Yellow}All Done!${End}\r\n"
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