# ffmpeg-build-script

This build script, is to support the NRCHKB project.  
in allowing a fully updatable ffmpeg build for multiple pi versions (arm), OS's and intel hosts.

Highlights

 - FFmpeg 5.0+ (Built for your platform)
 - 32 and 64 bit support
 - libfdk-aac (Built for your platform)
 - libx264 (Installed via apt, or will build from source as a fallback if not available)
 - h264_omx (32Bit only, Raspberry Pi only, deprecated)
 - h264_v4l2m2m (replaces h264_omx)

![image](./Menu1.png)

# How to Install

Copy the below and paste it in your terminal (ensure root)
```
bash <(curl -sL https://raw.githubusercontent.com/marcus-j-davies/nrchkb-ffmpeg-build/main/nrchkb-ffmpeg-build.sh)
```

