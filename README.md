INFO
==============
This project aim to simplify compilation of FFmpeg for android diffrent architecutres to one big apk file.

LICENSE
==============
Coypyright (C) 2012 Appunite.com
Licensed under the Apache License, Verision 2.0

FFmpeg and libvo-aacenc projects are distributed on theirs own license.

INSTALATION
==============
git clone git://github.com/appunite/AndroidFFmpeg.git AndroidFFmpeg
cd AndroidFFmpeg
git submodule init
git submodule update
cd FFmpegLibrary
cd jni

#setup vo-aacenc environment
cd vo-aacenc
autoreconf
cd ..

#build external libraries
export NDK=/your/path/to/android-ndk
./build_android.sh
make sure that files FFmpegLibrary/libs/{armeabi,armeabi-v7a,x86}/libffmpeg.so was created, otherwise you are in truble

#build ndk jni library
ndk-build

Import FFmpegLibrary and FFmpegExample to your eclipse
Run FFmpegExample as your android project 

MORE CODECS
============
If you nead more codecs:
#edit build_android.sh
#add more codecs in ffmpeg configuration section

#remove old ffmpeg build directory
rm -r ffmpeg-build
#build ffmpeg end supporting libraries
./build_android.sh
#during this process make sure that ffmpeg configuation goes without error
#after build make sure that files FFmpegLibrary/libs/{armeabi,armeabi-v7a,x86}/libffmpeg.so was created, otherwise you are in truble

#build your ndk library
ndk-build

refresh your FFmpegLibrary project in eclipse!!!!
build your FFmpegExample project 


CREDITS
=============
Library made by Jacek Marchwicki from Appunite.com

Thanks to Martin Böhme for writing tutorial: http://www.inb.uni-luebeck.de/~boehme/libavcodec_update.html
Thanks to Stephen Dranger for writing tutorial: http://dranger.com/ffmpeg/
Thanks to Liu Feipeng for writing blog: http://www.roman10.net/how-to-port-ffmpeg-the-program-to-androidideas-and-thoughts/
Thanks to ffmpeg team for writing cool stuff http://ffmpeg.org
Thanks to Alvaro for writing blog: http://odroid.foros-phpbb.com/t338-ffmpeg-compiled-with-android-ndk
Thanks to android-fplayer for sample code: http://code.google.com/p/android-fplayer/
Thanks to best-video-player for sample code: http://code.google.com/p/best-video-player/

