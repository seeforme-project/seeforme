package com.example.videocallapp.ui.main

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.videocallapp.R
import com.example.videocallapp.ui.videocall.VideoCallActivity

class CallActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Get room name from intent
        val room = intent.getStringExtra("callRoom") ?: "defaultRoom"

        // Launch the Daily video call activity
        val intent = Intent(this, VideoCallActivity::class.java)
        intent.putExtra("DAILY_ROOM_NAME", room)
        startActivity(intent)

        finish() // Close this activity
    }
}