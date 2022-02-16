#!/bin/bash

echo "----------------------------------------------"
echo "|           P&M FFMPEG Build Script          |"
echo "----------------------------------------------"
echo

Yellow=$'\e[1;33m'
End=$'\e[0m'

cd ~

# Insert RED warning to make sure no custom build or non apt ffmpeg is installed?

printf "${Yellow}Question - Is this a new install (n) or update (u):${End}"
read Option

Clean_directory(){
    sudo rm -rf FFmpeg
    sudo rm -rf fdk-aac
}

Install_dependencies(){
    printf "${Yellow}Install some build tools and static libs using apt - Press enter${End}"
    read
    sudo apt install -y pkg-config autoconf automake libtool libx264-dev git 
}

Install_libfdk(){
    printf "${Yellow}Downloading and installing libfdk from GitHub - Press enter${End}"
    read
    cd ~
    git clone https://github.com/mstorsjo/fdk-aac.git
    cd fdk-aac
    sudo ./autogen.sh
    sudo ./configure --prefix=/usr --enable-shared --enable-static
    sudo make install -j3
    sudo ldconfig
    cd ~
}
Install_FFmpeg(){
    printf "${Yellow}Downloading FFmpeg from GitHub - Press enter${End}"
    read
    cd ~
    git clone https://github.com/FFmpeg/FFmpeg.git
    cd FFmpeg
    printf "${Yellow}Running FFmpeg configure command - this may take a few minutes - Press enter${End}"
    read
    sudo ./configure --prefix=/usr --enable-nonfree --enable-gpl --enable-libfdk-aac --enable-libx264
    printf "${Yellow}Compiling and installing FFMPEG - this WILL take a while - Press enter${End}"
    read
    # compile FFmpeg:
    sudo make -j3
    # install FFmpeg:
    sudo make install -j1
    cd ~
    Clean_directory
    # So - if which ffmpeg returns nothing then we failed.
    # If we failed, we should not celebrate here.
    printf "${Yellow}All Done! - Enjoy${End}\n"
}

if [ "$Option" = "n" ]
 then
   Clean_directory
   Install_dependencies
   Install_libfdk
   Install_FFmpeg
fi

if [ "$Option" = "u" ]
 then
  Clean_directory
  Install_FFmpeg
fi
