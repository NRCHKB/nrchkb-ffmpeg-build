# ffmpeg-build-script

This build script, is to support the NRCHKB project.  
in allowing a fully updatable ffmpeg build for multiple pi versions and OS's

Highlights

 - FFmpeg 5.0+ (Built for your platform)
 - 64Bit support
 - libfdk-aac (Built for your platform)
 - libx264 (Installed via apt, or you can build as a fallback)
 - h264_omx (legacy)
 - h264_v4l2m2m (replaces h264_omx)

![image](https://user-images.githubusercontent.com/55892693/154429003-4a44ded7-73b2-45ee-8319-0691fdcf7c36.png)



Copy the below and paste it in your terminal (ensure root)
```
bash <(curl -sL https://raw.githubusercontent.com/marcus-j-davies/nrchkb-ffmpeg-build/main/nrchkb-ffmpeg-build.sh)
```

