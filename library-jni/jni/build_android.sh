#!/bin/bash
#
# build_android.sh
# Copyright (c) 2012 Jacek Marchwicki
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ "$NDK" = "" ]; then
	echo NDK variable not set, exiting
	echo "Use: export NDK=/your/path/to/android-ndk"
	exit 1
fi

# Get the newest arm-linux-androideabi version
if [ -z "$COMPILATOR_VERSION" ]; then
	DIRECTORIES=$NDK/toolchains/arm-linux-androideabi-*
	for i in $DIRECTORIES; do
		PROPOSED_NAME=${i#*$NDK/toolchains/arm-linux-androideabi-}
		if [[ $PROPOSED_NAME =~ ^[0-9\.]+$ ]] ; then
			echo "Available compilator version: $PROPOSED_NAME"
			COMPILATOR_VERSION=$PROPOSED_NAME
		fi
	done
fi

if [ -z "$COMPILATOR_VERSION" ]; then
	echo "Could not find compilator"
	exit 1
fi

if [ ! -d $NDK/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION ]; then
	echo $NDK/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION does not exist
	exit 1
fi
echo "Using compilator version: $COMPILATOR_VERSION"

OS_ARCH=`basename $NDK/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/*`
echo "Using architecture: $OS_ARCH"


function setup_paths
{
	export PLATFORM=$NDK/platforms/$PLATFORM_VERSION/arch-$ARCH/
	if [ ! -d $PLATFORM ]; then
		echo $PLATFORM does not exist
		exit 1
	fi
	echo "Using platform: $PLATFORM"
	export PATH=${PATH}:$PREBUILT/bin/
	export CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
	export CFLAGS=$OPTIMIZE_CFLAGS
	export CPPFLAGS="$CFLAGS"
	export CFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"
	export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
	export AS="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
	export CC="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
	export NM="${CROSS_COMPILE}nm"
	export LD="${CROSS_COMPILE}ld"
	export STRIP="${CROSS_COMPILE}strip"
	export RANLIB="${CROSS_COMPILE}ranlib"
	export AR="${CROSS_COMPILE}ar"
	export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog"
	export PKG_CONFIG_LIBDIR=$(pwd)/$PREFIX/lib/pkgconfig/
	export PKG_CONFIG_PATH=$(pwd)/$PREFIX/lib/pkgconfig/

	if [ ! -f $CC ]; then
		print "Gcc does not exists in path: $CC"
		exit 1;
	fi
}

function build_x264
{
	cd x264
	./configure --prefix=$(pwd)/$PREFIX --host=$ARCH-linux --enable-static $ADDITIONAL_CONFIGURE_FLAG || exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}

function build_amr
{
	cd vo-amrwbenc
	./configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-dependency-tracking \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}

function build_aac
{
	cd vo-aacenc
	export PKG_CONFIG_LIBDIR=$(pwd)/$PREFIX/lib/pkgconfig/
	export PKG_CONFIG_PATH=$(pwd)/$PREFIX/lib/pkgconfig/
	./configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-dependency-tracking \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}
function build_freetype2
{
	cd freetype2
	./configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-dependency-tracking \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}
function build_ass
{
	cd libass
	./configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-fontconfig \
	    --disable-dependency-tracking \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make V=1 -j4 install || exit 1
	cd ..
}
function build_fribidi
{
	cd fribidi
	./configure \
	    --prefix=$(pwd)/$PREFIX \
	    --host=$ARCH-linux \
	    --disable-bin \
	    --disable-dependency-tracking \
	    --disable-shared \
	    --enable-static \
	    --with-pic \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1

	make clean || exit 1
	make -j4 install || exit 1
	cd ..
}
function build_ffmpeg
{
	cd ffmpeg
	./configure --target-os=linux \
	    --prefix=$PREFIX \
	    --enable-cross-compile \
	    --extra-libs="-lgcc" \
	    --arch=$ARCH \
	    --cc=$CC \
	    --cross-prefix=$CROSS_PREFIX \
	    --nm=$NM \
	    --sysroot=$PLATFORM \
	    --extra-cflags=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS " \
	    --disable-shared \
	    --enable-static \
	    --enable-runtime-cpudetect \
	    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -nostdlib -lc -lm -ldl -llog -L$PREFIX/lib" \
	    --extra-cflags="-I$PREFIX/include" \
	    --disable-everything \
	    --enable-pthreads \
	    --enable-libass \
	    --enable-libvo-aacenc \
	    --enable-libvo-amrwbenc \
	    --enable-hwaccel=h264_vaapi \
	    --enable-hwaccel=h264_vaapi \
	    --enable-hwaccel=h264_dxva2 \
	    --enable-hwaccel=mpeg4_vaapi \
	    --enable-demuxer=mov \
	    --enable-demuxer=h264 \
	    --enable-demuxer=mpegvideo \
	    --enable-demuxer=h263 \
	    --enable-demuxer=mpegps \
	    --enable-demuxer=mjpeg \
	    --enable-demuxer=rtsp \
	    --enable-demuxer=rtp \
	    --enable-demuxer=hls \
	    --enable-demuxer=matroska \
	    --enable-muxer=rtsp \
	    --enable-muxer=mp4 \
	    --enable-muxer=mov \
	    --enable-muxer=mjpeg \
	    --enable-muxer=matroska \
	    --enable-protocol=crypto \
	    --enable-protocol=jni \
	    --enable-protocol=file \
	    --enable-protocol=rtp \
	    --enable-protocol=tcp \
	    --enable-protocol=udp \
	    --enable-protocol=applehttp \
	    --enable-protocol=hls \
	    --enable-protocol=http \
	    --enable-decoder=xsub \
	    --enable-decoder=jacosub \
	    --enable-decoder=dvdsub \
	    --enable-decoder=dvbsub \
	    --enable-decoder=subviewer \
	    --enable-decoder=rawvideo \
	    --enable-encoder=rawvideo \
	    --enable-decoder=mjpeg \
	    --enable-encoder=mjpeg \
	    --enable-decoder=h263 \
	    --enable-decoder=mpeg4 \
	    --enable-encoder=mpeg4 \
	    --enable-decoder=h264 \
	    --enable-encoder=h264 \
	    --enable-decoder=aac \
	    --enable-encoder=aac \
	    --enable-parser=h264 \
	    --enable-encoder=mp2 \
	    --enable-decoder=mp2 \
	    --enable-encoder=libvo_amrwbenc \
	    --enable-decoder=amrwb \
	    --enable-muxer=mp2 \
	    --enable-bsfs \
	    --enable-decoders \
	    --enable-encoders \
	    --enable-parsers \
	    --enable-hwaccels \
	    --enable-muxers \
	    --enable-avformat \
	    --enable-avcodec \
	    --enable-avresample \
	    --enable-zlib \
	    --disable-doc \
	    --disable-ffplay \
	    --disable-ffmpeg \
	    --disable-ffplay \
	    --disable-ffprobe \
	    --disable-ffserver \
	    --disable-avfilter \
	    --disable-avdevice \
	    --enable-nonfree \
	    --enable-version3 \
	    --enable-memalign-hack \
	    --enable-asm \
	    $ADDITIONAL_CONFIGURE_FLAG \
	    || exit 1
	make clean || exit 1
	make -j4 install || exit 1

	cd ..
}

function build_one {
	cd ffmpeg
	$LD -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -L$PREFIX/lib  -soname $SONAME -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $OUT_LIBRARY -lavcodec -lavformat -lavresample -lavutil -lswresample -lass -lfreetype -lfribidi -lswscale -lvo-aacenc -lvo-amrwbenc -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker -zmuldefs $PREBUILT/lib/gcc/$EABIARCH/$COMPILATOR_VERSION/libgcc.a || exit 1
	cd ..
}

#arm v5
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv5
OPTIMIZE_CFLAGS="-marm -march=$CPU"
PREFIX=../ffmpeg-build/armeabi
OUT_LIBRARY=$PREFIX/libffmpeg.so
ADDITIONAL_CONFIGURE_FLAG=
SONAME=libffmpeg.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
PLATFORM_VERSION=android-5
setup_paths
build_amr
build_aac
build_fribidi
build_freetype2
build_ass
build_ffmpeg
build_one

#x86
EABIARCH=i686-linux-android
ARCH=x86
OPTIMIZE_CFLAGS="-m32"
PREFIX=../ffmpeg-build/x86
OUT_LIBRARY=$PREFIX/libffmpeg.so
ADDITIONAL_CONFIGURE_FLAG=--disable-asm
SONAME=libffmpeg.so
PREBUILT=$NDK/toolchains/x86-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
PLATFORM_VERSION=android-9
setup_paths
build_amr
build_aac
build_fribidi
build_freetype2
build_ass
build_ffmpeg
build_one

#mips
EABIARCH=mipsel-linux-android
ARCH=mips
OPTIMIZE_CFLAGS="-EL -march=mips32 -mips32 -mhard-float"
PREFIX=../ffmpeg-build/mips
OUT_LIBRARY=$PREFIX/libffmpeg.so
ADDITIONAL_CONFIGURE_FLAG="--disable-mips32r2"
SONAME=libffmpeg.so
PREBUILT=$NDK/toolchains/mipsel-linux-android-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
PLATFORM_VERSION=android-9
setup_paths
build_amr
build_aac
build_fribidi
build_freetype2
build_ass
build_ffmpeg
build_one

#arm v7vfpv3
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
PREFIX=../ffmpeg-build/armeabi-v7a
OUT_LIBRARY=$PREFIX/libffmpeg.so
ADDITIONAL_CONFIGURE_FLAG=
SONAME=libffmpeg.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
PLATFORM_VERSION=android-5
setup_paths
build_amr
build_aac
build_fribidi
build_freetype2
build_ass
build_ffmpeg
build_one

#arm v7 + neon (neon also include vfpv3-32)
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8 -mthumb -D__thumb__ "
PREFIX=../ffmpeg-build/armeabi-v7a-neon
OUT_LIBRARY=../ffmpeg-build/armeabi-v7a/libffmpeg-neon.so
ADDITIONAL_CONFIGURE_FLAG=--enable-neon
SONAME=libffmpeg-neon.so
PREBUILT=$NDK/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
PLATFORM_VERSION=android-9
setup_paths
build_amr
build_aac
build_fribidi
build_freetype2
build_ass
build_ffmpeg
build_one


echo "BUILD SUCESS"
