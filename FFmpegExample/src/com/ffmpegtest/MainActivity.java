package com.ffmpegtest;

import java.io.File;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.os.Bundle;
import android.os.Environment;
import android.support.v4.widget.CursorAdapter;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.ffmpegtest.adapter.MainAdapter;

public class MainActivity extends Activity implements OnItemClickListener {

	private ListView mListView;
	private CursorAdapter mAdapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main_activity);
		
		MatrixCursor cursor = new MatrixCursor(MainAdapter.PROJECTION);
		cursor.addRow(new Object[] {
				1,
				"Jasmine Sullivan unencrypted",
				getSDCardFile("airbender/videos/JasmineSullivan-DreamBig_ENG-ENCODESTREAM.mp4"),
				null });
		cursor.addRow(new Object[] {
				1,
				"Jennifer Hudson unencrypted",
				getSDCardFile("airbender/videos/JenniferHudson-IfThisIsntLove_ENG-ENCODESTREAM.mp4"),
				null });
		cursor.addRow(new Object[] {
				1,
				"Kings Of Leon-Charmer unencrypted",
				getSDCardFile("airbender/videos/KingsOfLeon-Charmer_ENG-ENCODESTREAM.mp4"),
				null });
		cursor.addRow(new Object[] {
				1,
				"Kings Of Leon-Charmer unencrypted",
				getSDCardFile("airbender/videos/Lenka-TheShow_ENG-ENCODESTREAM.mp4"),
				null });
		cursor.addRow(new Object[] {
				1,
				"Kings Of Leon-Charmer unencrypted",
				getSDCardFile("airbender/videos/Videoguides-Riga_SIL_engrus_1500.mp4"),
				null });
		cursor.addRow(new Object[] {
				2,
				"Hungers games trailer",
				"http://192.168.1.105:1935/vod/mp4:HungerGamesTrailer800.mp4/playlist.m3u8",
				null });
		cursor.addRow(new Object[] {
				3,
				"Apple sample",
				"http://devimages.apple.com.edgekey.net/resources/http-streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8",
				null });
		cursor.addRow(new Object[] {
				4,
				"Apple advenced sample",
				"https://devimages.apple.com.edgekey.net/resources/http-streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8",
				null });
		cursor.addRow(new Object[] {
				1,
				"Encrypted file",
				getSDCardFile("encrypted.mp4"),
				"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" });
		
		
		mAdapter = new MainAdapter(this);
		mAdapter.swapCursor(cursor);
		
		mListView = (ListView) findViewById(android.R.id.list);
		mListView.setAdapter(mAdapter);
		mListView.setOnItemClickListener(this);
	}
	
	private static String getSDCardFile(String file) {
		File videoFile = new File(Environment.getExternalStorageDirectory(),
				file);
		return "file://" + videoFile.getAbsolutePath();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.main_activity, menu);
		return true;
	}

	@Override
	public void onItemClick(AdapterView<?> listView, View view, int position, long id) {
		Cursor cursor = (Cursor) mAdapter.getItem(position);
		String url = cursor.getString(MainAdapter.PROJECTION_URL);
		Intent intent = new Intent(AppConstants.VIDEO_PLAY_ACTION);
		intent.putExtra(AppConstants.VIDEO_PLAY_ACTION_EXTRA_URL, url);
		String encryptionKey = cursor.getString(MainAdapter.PROJECTION_ENCRYPTION_KEY);
		if (encryptionKey != null) {
			intent.putExtra(AppConstants.VIDEO_PLAY_ACTION_EXTRA_ENCRYPTION_KEY, encryptionKey);
		}
		startActivity(intent);
	}

}
