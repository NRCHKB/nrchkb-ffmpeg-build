# ffmpeg-build-script

This build script, is to support the NRCHKB project in allowing a fully updatable FFmpeg builds. 
It is designed for multiple Raspberry Pi versions (arm), OS's and intel hosts.

Highlights

- FFmpeg 5.0+ (Built for your platform)
- 32 and 64 bit support
- libfdk-aac (Built for your platform)
- libx264 (Installed via apt, or will build from source as a fallback if not available)
- h264_omx (32Bit only, Raspberry Pi only, deprecated)
- h264_v4l2m2m (replaces h264_omx)
- Ability to add extra compile flags

Tested systems

- Raspberry Pi Zero W1 (Bullseye - 32Bit)
- Raspberry Pi Zero W2 Bullseye - 64Bit)
- Raspberry Pi 3A+ (Bullseye - 64Bit)
- Raspberry Pi 3B+ (Buster - 32Bit)
- Raspberry Pi 4 (Buster - 32Bit)
- Raspberry Pi 4 (Bullseye - 64Bit)
- Intel Host (Ubuntu - 32Bit)

![image](./Menu1.png)

# How to Install

Copy the below and paste it in your terminal (ensure root)

```
bash <(curl -sL https://raw.githubusercontent.com/marcus-j-davies/nrchkb-ffmpeg-build/main/nrchkb-ffmpeg-build.sh)
```

