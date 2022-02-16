# ffmpeg-build-script

This build script, is to support the NRCHKB project.  
in allowing a fully updatable ffmpeg build for multiple pi versions and OS's

Highlights

 - FFmpeg 5.0+ (Built for your platform)
 - libfdk-aac (Built for your platform)
 - libx264 (Installed via apt)
 - h264_omx (legacy)
 - h264_v4l2m2m (replaces h264_omx)

![image](https://user-images.githubusercontent.com/55892693/154356874-1d4a71cf-476d-4ce7-b48f-e0a40cca4968.png)


Copy the below and paste it in your terminal (ensure root)
```
bash <(curl -sL https://raw.githubusercontent.com/marcus-j-davies/ffmpeg-build-script/main/ffmpeg-build.sh)
```

