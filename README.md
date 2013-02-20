# AndroidFFmpegLibrary
This project aims to create **working** library providing playing and converting video files in android via ffmpeg libraries.
We rather want to use ffmpeg library without modifications to facilitate updating of ffmpeg core.

![Application screenshot](http://s12.postimage.org/o528w8jst/Screenshot1.png)

This project aim to simplify compilation of FFmpeg for android different architectures to one big apk file.

## Moved source code
I moved project source code to our company review system https://review.appunite.com
because I am used to benefit from review systems like Gerrit. There you can find newest not yet accepted source code. If you do not care of newest source code or contributing software you can just use github where you can reaches accepted commits.

	git clone https://review.appunite.com/androidffmpeg
	
or

	git clone https://github.com/appunite/AndroidFFmpeg.git

## License
Copyright (C) 2012 Appunite.com
Licensed under the Apache License, Verision 2.0

FFmpeg, libvo-aacenc, vo-amrwbenc, yuv2rgb and others libraries projects are distributed on theirs own license.

## Patent disclaimer
We do not grant of patent rights.
Some codecs use patented techniques and before use those parts of library you have to buy thrid-party patents.

## Pre-requirments
on mac: you have to install xcode and command tools from xcode preferences
you have to install (on mac you can use brew command from homebrew):
you have to install:
- autoconf
- autoconf-archive
- automake
- pkg-config

on Debian/Ubuntu - you can use apt-get

on Mac - you can use tool brew from homebrew project. You have additionally install xcode. 

## Bug reporting

**Please read instruciton very carefully**. A lot of people had trouble because they did not read this with attention. **If you have some problem do not send me emails**. First: look on past issues on github. Than: try figure out problem with google. If you did not find solution then you can ask on github issue tracker.

## Installation

### Before start
if you have a problem with certificate add *GIT\_SSL\_NO\_VERIFY=true* before git submodule update line

	GIT_SSL_NO_VERIFY=true  git submodule update

Im sorry about this certificate issue, but never is enough time to fix problems like those

**If (only if) you have ssh key in appunite review system** you should setup global alias in *~/.gitconfig* file.

	git config --global url.ssh://review.appunite.com.insteadOf https://review.appunite.com

### Go to the work
downloading source code 

	git clone https://review.appunite.com/androidffmpeg AndroidFFmpeg
	cd AndroidFFmpeg
	git submodule init
	git submodule sync #if you are updating source code
	git submodule update
	cd FFmpegLibrary
	cd jni

setup freetype environemtn

	cd freetype
	./autogen.sh
	cd ..

setup fribidi environemtn

	cd fribidi
	autoreconf -ivf
	cd ..

setup libass environemtn

	cd libass
	autoreconf -ivf
	cd ..

setup vo-aacenc environment

	cd vo-aacenc
	autoreconf
	cd ..

setup vo-amrwbenc environment

	cd vo-amrwbenc
	autoreconf
	cd ..

build external libraries

	export NDK=/your/path/to/android-ndk
	./build_android.sh
	
make sure that files FFmpegLibrary/jni/ffmpeg-build/{armeabi,armeabi-v7a,x86}/libffmpeg.so was created, otherwise you are in truble

build ndk jni library

	ndk-build

make sure that files FFmpegLibrary/libs/{armeabi,armeabi-v7a,x86}/libffmpeg.so was created, otherwise you are in truble

build your project

	android update lib-project -p FFmpegLibrary
	android update project -p FFmpegExample
	cd FFmpegExample
	ant debug
	ant installd

or create new projects from FFmpegLibrary and FFmpegExample source directories in your eclipse. 
Run FFmpegExample as your android project.
If you have adt >= 20.0 you can click right mouse button on project and FFmpegLibrary project and "Android->Add native support".

## More codecs
If you nead more codecs:
- edit build_android.sh
- add more codecs in ffmpeg configuration section
- remove old ffmpeg-build directory by

		rm -r ffmpeg-build
	
- build ffmpeg end supporting libraries

		./build_android.sh
		
	During this process make sure that ffmpeg configuration goes without error.
	
	After build make sure that files FFmpegLibrary/jni/ffmpeg-build/{armeabi,armeabi-v7a,x86}/libffmpeg.so was created, otherwise you are in truble

- build your ndk library

		ndk-build

- refresh your FFmpegLibrary project in eclipse!!!!
- build your FFmpegExample project 


## Credits
Library made by Jacek Marchwicki from Appunite.com

- Thanks to Martin Böhme for writing tutorial: http://www.inb.uni-luebeck.de/~boehme/libavcodec_update.html
- Thanks to Stephen Dranger for writing tutorial: http://dranger.com/ffmpeg/
- Thanks to Liu Feipeng for writing blog: http://www.roman10.net/how-to-port-ffmpeg-the-program-to-androidideas-and-thoughts/
- Thanks to ffmpeg team for writing cool stuff http://ffmpeg.org
- Thanks to Alvaro for writing blog: http://odroid.foros-phpbb.com/t338-ffmpeg-compiled-with-android-ndk
- Thanks to android-fplayer for sample code: http://code.google.com/p/android-fplayer/
- Thanks to best-video-player for sample code: http://code.google.com/p/best-video-player/
- Thanks to Robin Watts for his work in yuv2rgb converter http://wss.co.uk/pinknoise/yuv2rgb/
- Thanks to Mohamed Naufal (https://github.com/hexene) and Martin Storsjö (https://github.com/mstorsjo) for theirs work on sample code for stagefright/openmax integration layer.
