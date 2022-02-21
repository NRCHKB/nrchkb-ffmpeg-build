# ffmpeg-build-script

This build script, is to support the NRCHKB project in allowing fully updatable FFmpeg builds.  
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

- Bullseye (32Bit)
  - Raspberry Pi Zero W1

- Bullseye (64Bit)
  - Raspberry Pi Zero W2
  - Raspberry Pi 4 
  - Raspberry Pi 3A+

- Buster (32Bit)
  - Raspberry Pi 4
  - Raspberry Pi 3B+
  - Raspberry Pi 3B

- Ubuntu (64 Bit)
  - Intel

- Alpine (64Bit)
  - ARM64

- Alpine (32Bit)
  - ARM



![image](./Menu1.png)

# How to Install

Copy the below and paste it in your terminal.

Note: If your OS is Alpine, install curl and bash first.
```
apk add curl bash
```
Then

```
bash <(curl -sL https://raw.githubusercontent.com/NRCHKB/nrchkb-ffmpeg-build/main/build-bootstrap.sh)
```




