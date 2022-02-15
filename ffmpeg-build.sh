#!/bin/bash

echo "----------------------------------------------"
echo "|           P&M FFMPEG Build Script          |"
echo "----------------------------------------------"
echo

Yellow=$'\e[1;33m'
End=$'\e[0m'

printf "Question - Is this a fresh install (f) or update (u):"
read Option

ClearStuff(){
    sudo rm -rf FFmpeg
    sudo rm -rf fdk-aac
}

PreInstall(){
    printf "${Yellow}We're about to install some build tools and static libs - Press enter${End}"
    read
    sudo apt install -y pkg-config autoconf automake libtool libx264-dev git 
}

InstallDevStuff(){
    printf "${Yellow}We're about to pull down and build libfdk-aac  - Press enter${End}"  
    read
    git clone https://github.com/mstorsjo/fdk-aac.git
    cd ./fdk-aac
    sudo ./autogen.sh
    sudo ./configure --prefix=/usr --enable-shared --enable-static
    sudo make install -j3
    sudo ldconfig
    cd ../
}
 InstallFFMPEG(){
      printf "${Yellow}We're about to pull down the latest FFMPEG source - Press enter${End}"
      read
      git clone https://github.com/FFmpeg/FFmpeg.git
      cd ./FFmpeg
      printf "${Yellow}We're about to run the configure command - this may take a few minutes - Press enter${End}"
      read
      sudo ./configure --prefix=/usr --enable-nonfree --enable-gpl --enable-libfdk-aac --enable-libx264
      printf "${Yellow}We're about to compile and install FFMPEG - this WILL take a while - Press enter${End}"
      read
      sudo make install -j3
      ClearStuff
      printf "${Yellow}All Done! - Enjoy${End}"
 }

if [ "$Option" = "f" ]
 then
   ClearStuff
   PreInstall
   InstallDevStuff
   InstallFFMPEG
fi

if [ "$Option" = "u" ]
 then
  ClearStuff
  InstallFFMPEG
fi
