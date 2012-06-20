LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

#presets - do not tuch
FEATURE_NEON:=
FEATURE_VFPV3:=
LIBRARY_PROFILER:=
LIBRARY_YUV2RGB:=


#settings
#if armeabi-v7a
ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
	# add neon optimization code (only armeabi-v7a)
	FEATURE_NEON:=yes
	
	# add vfpv3-d32 optimization code (only armeabi-v7a)
	FEATURE_VFPV3:=yes
else

endif

#if armeabi or armeabi-v7a
ifeq ($(TARGET_ARCH_ABI),$(filter $(TARGET_ARCH_ABI),armeabi armeabi-v7a))
	# add profiler (only arm)
	#LIBRARY_PROFILER:=yes

	# add yuv2rgb (only arm)
	LIBRARY_YUV2RGB:=yes
endif




#includes
ifdef LIBRARY_YUV2RGB
	include $(LOCAL_PATH)/yuv2rgb/Android.mk
endif

ifdef LIBRARY_PROFILER
	include $(LOCAL_PATH)/android-ndk-profiler-3.1/android-ndk-profiler.mk
endif

include $(CLEAR_VARS)
LOCAL_MODULE := ffmpeg-prebuilt
LOCAL_SRC_FILES := ffmpeg-build/$(TARGET_ARCH_ABI)/libffmpeg.so
LOCAL_EXPORT_C_INCLUDES := ffmpeg-build/$(TARGET_ARCH_ABI)/include
LOCAL_EXPORT_LDLIBS := ffmpeg-build/$(TARGET_ARCH_ABI)/libffmpeg.so
LOCAL_PRELINK_MODULE := true
include $(PREBUILT_SHARED_LIBRARY)

ifdef FEATURE_NEON
	include $(CLEAR_VARS)
	LOCAL_MODULE := ffmpeg-prebuilt-neon
	LOCAL_SRC_FILES := ffmpeg-build/$(TARGET_ARCH_ABI)/libffmpeg-neon.so
	LOCAL_EXPORT_C_INCLUDES := ffmpeg-build/$(TARGET_ARCH_ABI)-neon/include
	LOCAL_EXPORT_LDLIBS := ffmpeg-build/$(TARGET_ARCH_ABI)/libffmpeg-neon.so
	LOCAL_PRELINK_MODULE := true
	include $(PREBUILT_SHARED_LIBRARY)
endif

ifdef FEATURE_VFPV3
	include $(CLEAR_VARS)
	LOCAL_MODULE := ffmpeg-prebuilt-vfpv3
	LOCAL_SRC_FILES := ffmpeg-build/$(TARGET_ARCH_ABI)/libffmpeg-vfpv3.so
	LOCAL_EXPORT_C_INCLUDES := ffmpeg-build/$(TARGET_ARCH_ABI)-vfpv3/include
	LOCAL_EXPORT_LDLIBS := ffmpeg-build/$(TARGET_ARCH_ABI)/libffmpeg-vfpv3.so
	LOCAL_PRELINK_MODULE := true
	include $(PREBUILT_SHARED_LIBRARY)
endif




#ffmpeg-jni library
include $(CLEAR_VARS)
LOCAL_ALLOW_UNDEFINED_SYMBOLS=false
LOCAL_MODULE := ffmpeg-jni
LOCAL_SRC_FILES := ffmpeg-jni.c player.c queue.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/ffmpeg-build/$(TARGET_ARCH_ABI)/include
LOCAL_SHARED_LIBRARY := ffmpeg-prebuilt

#if enabled profiler add it
ifdef LIBRARY_PROFILER
	LOCAL_CFLAGS += -pg -g -DPROFILER
	LOCAL_STATIC_LIBRARIES += andprof
endif

ifdef FEATURE_VFPV3
	LOCAL_SHARED_LIBRARY += ffmpeg-prebuilt-vfpv3
endif

ifdef FEATURE_NEON
	LOCAL_SHARED_LIBRARY += ffmpeg-prebuilt-neon
endif

ifdef LIBRARY_YUV2RGB
	LOCAL_CFLAGS += -DYUV2RGB
	LOCAL_STATIC_LIBRARIES += yuv2rgb
endif

LOCAL_LDLIBS  := -llog -ljnigraphics -lz -lm -g $(LOCAL_PATH)/ffmpeg-build/$(TARGET_ARCH_ABI)/libffmpeg.so
include $(BUILD_SHARED_LIBRARY)



#nativetester-jni library
include $(CLEAR_VARS)
LOCAL_ALLOW_UNDEFINED_SYMBOLS=false
LOCAL_MODULE := nativetester-jni
LOCAL_SRC_FILES := nativetester-jni.c nativetester.c
LOCAL_STATIC_LIBRARIES += cpufeatures
LOCAL_LDLIBS  := -llog
include $(BUILD_SHARED_LIBRARY)




$(call import-module,cpufeatures)

