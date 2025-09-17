package com.example.videocallapp.ui.registration
import com.example.videocallapp.ui.videocall.VideoCallActivity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.videocallapp.R
import com.example.videocallapp.databinding.ActivityRegistrationBinding
import com.example.videocallapp.ui.main.MainActivity

class RegistrationActivity : AppCompatActivity() {

    private lateinit var binding: ActivityRegistrationBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityRegistrationBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Remove the fragment transaction code that's causing errors

        // This is for direct UI interaction
        binding.btnRegister.setOnClickListener {
            val username = binding.editTextUsername.text.toString().trim()
            val password = binding.editTextPassword.text.toString()

            // Validate
            if (username.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            // Add this to your onCreate method
            findViewById<Button>(R.id.btnStartCall).setOnClickListener {
                val intent = Intent(this, VideoCallActivity::class.java)
                startActivity(intent)
            }

            // Complete registration
            completeRegistration(username)
        }
    }

    // Add this method to handle registration completion
    fun completeRegistration(username: String) {
        Log.d("Registration", "Registration completed with username: $username")

        // Save user credentials
        getSharedPreferences("user_prefs", MODE_PRIVATE)
            .edit()
            .putBoolean("logged_in", true)
            .putString("username", username)
            .apply()

        Toast.makeText(this, "Registration successful!", Toast.LENGTH_SHORT).show()

        // Navigate to MainActivity
        val intent = Intent(this, MainActivity::class.java)
        startActivity(intent)
        finish()
    }
}