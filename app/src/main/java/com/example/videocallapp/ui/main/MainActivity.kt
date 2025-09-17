package com.example.videocallapp.ui.main

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.videocallapp.databinding.ActivityMainBinding
import com.example.videocallapp.ui.main.CallActivity
import com.example.videocallapp.ui.login.LoginActivity

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Check if user is logged in
        if (!isUserLoggedIn()) {
            // User is not logged in, redirect to LoginActivity
            val intent = Intent(this, LoginActivity::class.java)
            startActivity(intent)
            finish() // Close MainActivity so user can't go back
            return
        }

        // User is logged in, show main UI
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnStartCall.setOnClickListener {
            val intent = Intent(this, CallActivity::class.java)
            intent.putExtra("callRoom", "room-${System.currentTimeMillis()}")
            startActivity(intent)
        }

        // Add logout functionality
        binding.btnLogout.setOnClickListener {
            // Clear login state
            getSharedPreferences("user_prefs", MODE_PRIVATE)
                .edit()
                .putBoolean("logged_in", false)
                .apply()

            // Redirect to login
            val intent = Intent(this, LoginActivity::class.java)
            startActivity(intent)
            finish()
        }
    }

    private fun isUserLoggedIn(): Boolean {
        // Check if user is logged in via SharedPreferences
        val prefs = getSharedPreferences("user_prefs", MODE_PRIVATE)
        return prefs.getBoolean("logged_in", false)
    }
}