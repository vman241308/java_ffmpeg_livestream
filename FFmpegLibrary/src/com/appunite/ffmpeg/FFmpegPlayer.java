/*
 * FFmpegPlayer.java
 * Copyright (c) 2012 Jacek Marchwicki
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package com.appunite.ffmpeg;

import android.app.Activity;
import android.graphics.Bitmap;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;

public class FFmpegPlayer {
	private FFmpegListener mpegListener;
	private final RenderedFrame mRenderedFrame = new RenderedFrame();

	private int mNativePlayer;
	private final Activity activity;

	static {
		NativeTester nativeTester = new NativeTester();
		if (nativeTester.isNeon()) {
			System.loadLibrary("ffmpeg-neon");			
		} else if (nativeTester.isVfpv3()) {
			System.loadLibrary("ffmpeg-vfpv3");
		} else {
			System.loadLibrary("ffmpeg");			
		}
		System.loadLibrary("ffmpeg-jni");
	}

	private Runnable updateTimeRunnable = new Runnable() {

		@Override
		public void run() {
			mpegListener.onUpdateTime(mCurrentTimeS, mVideoDurationS);
		}

	};

	private int mCurrentTimeS;
	private int mVideoDurationS;

	public static class RenderedFrame {
		public Bitmap bitmap;
		public int height;
		public int width;
	}

	public FFmpegPlayer(FFmpegDisplay videoView, Activity activity, FFmpegListener mpegListener) {
		this.activity = activity;
		this.mpegListener = mpegListener;
		int error = initNative();
		if (error != 0)
			throw new RuntimeException(String.format("Could not initialize player: %d", error));
		videoView.setMpegPlayer(this);
	}
	
	@Override
	protected void finalize() throws Throwable {
		deallocNative();
		super.finalize();
	}
	
	private native int initNative();
	private native void deallocNative();
	
	private native int setDataSourceNative(String url);
	private native int stopNative();

	public native void renderFrameStart();
	public native void renderFrameStop();	
	private native Bitmap renderFrameNative() throws InterruptedException;
	public native void releaseFrame();

	private native int getVideoDurationNative();
	
	public void stop() {
//		new Thread() {
//			public void run() {
				stopNative();
//			};
//		}.start();
	}
	
	private native void pauseNative() throws NotPlayingException;
	private native void resumeNative() throws NotPlayingException;
	
	public void pause() {
		try {
			pauseNative();
		} catch (NotPlayingException e) {
			e.printStackTrace();
		}
	}
	
	public void resume() {
		try {
			resumeNative();
		} catch (NotPlayingException e) {
			e.printStackTrace();
		}
	}

	private Bitmap prepareFrame(int width, int height) {
		// Bitmap bitmap =
		// Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
		Bitmap bitmap = Bitmap.createBitmap(width, height,
				Bitmap.Config.RGB_565);
		this.mRenderedFrame.height = height;
		this.mRenderedFrame.width = width;
		return bitmap;
	}

	private void onUpdateTime(int currentSec, int maxSec) {

		this.mCurrentTimeS = currentSec;
		this.mVideoDurationS = maxSec;
		activity.runOnUiThread(updateTimeRunnable);
	}

	private AudioTrack prepareAudioTrack(int sampleRateInHz,
			int numberOfChannels) {

		int channelConfig;

		if (numberOfChannels == 1) {
			channelConfig = AudioFormat.CHANNEL_OUT_MONO;
		} else if (numberOfChannels == 2) {
			channelConfig = AudioFormat.CHANNEL_OUT_STEREO;
		} else if (numberOfChannels == 3) {
			channelConfig = AudioFormat.CHANNEL_OUT_FRONT_CENTER
					| AudioFormat.CHANNEL_OUT_FRONT_RIGHT
					| AudioFormat.CHANNEL_OUT_FRONT_LEFT;
		} else if (numberOfChannels == 4) {
			channelConfig = AudioFormat.CHANNEL_OUT_QUAD;
		} else if (numberOfChannels == 5) {
			channelConfig = AudioFormat.CHANNEL_OUT_QUAD
					| AudioFormat.CHANNEL_OUT_LOW_FREQUENCY;
		} else if (numberOfChannels == 6) {
			channelConfig = AudioFormat.CHANNEL_OUT_5POINT1;
		} else if (numberOfChannels == 8) {
			channelConfig = AudioFormat.CHANNEL_OUT_7POINT1;
		} else {
			// TODO
			throw new RuntimeException(
					String.format(
							"Could not play audio track with this number of channels: %d",
							numberOfChannels));
		}
		int minBufferSize = AudioTrack.getMinBufferSize(sampleRateInHz,
				channelConfig, AudioFormat.ENCODING_PCM_16BIT);
		AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC,
				sampleRateInHz, channelConfig, AudioFormat.ENCODING_PCM_16BIT,
				minBufferSize, AudioTrack.MODE_STREAM);
		return audioTrack;
	}

	private void setVideoListener(FFmpegListener mpegListener) {
		this.mpegListener = mpegListener;
	}

	public void setDataSource(String url) throws FFmpegError {
		int err = this.setDataSourceNative(url);
		if (err != 0)
			throw new FFmpegError(err);
	}

	public RenderedFrame renderFrame() throws InterruptedException {
		this.mRenderedFrame.bitmap = this.renderFrameNative();
		return this.mRenderedFrame;
	}
}
