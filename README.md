# ffmpeg-build-script

This build script, is to support the NRCHKB project.  
in allowing a fully updatable ffmpeg build for multiple pi versions and OS's

Highlights

 - FFmpeg 5.0+ (Built for your platform)
 - 64Bit support
 - libfdk-aac (Built for your platform)
 - libx264 (Installed via apt, or will build as a fallback if not available)
 - h264_omx (legacy)
 - h264_v4l2m2m (replaces h264_omx)

![image](https://user-images.githubusercontent.com/55892693/154566224-ed54b348-a2f7-4624-964d-cc8dc914f528.png)

Copy the below and paste it in your terminal (ensure root)
```
bash <(curl -sL https://raw.githubusercontent.com/marcus-j-davies/nrchkb-ffmpeg-build/main/nrchkb-ffmpeg-build.sh)
```

