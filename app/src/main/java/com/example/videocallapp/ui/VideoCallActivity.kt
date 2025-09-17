package com.example.videocallapp.ui.videocall

import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ToggleButton
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import co.daily.CallClient
import co.daily.CallClientListener
import co.daily.model.OutboundMediaType
import co.daily.model.Participant
import co.daily.model.ParticipantId
import co.daily.settings.InputSettings
import co.daily.view.VideoView
import com.example.videocallapp.R
import androidx.multidex.MultiDexApplication

class VideoCallActivity : AppCompatActivity() {
    private val TAG: String = "VideoCallActivity"
    private lateinit var toggleCamera: ToggleButton
    private lateinit var toggleMicrophone: ToggleButton

    // Replace with your Daily room URL
    private val DAILY_ROOM_URL = "https://connectspace.daily.co/connectspace"

    private val requestPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { result ->
            if (result.values.any { !it }) {
                checkPermissions()
            } else {
                // Permission is granted, we can initialize the call
                initializeCallClient()
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_video_call)

        toggleCamera = findViewById(R.id.toggleCamera)
        toggleMicrophone = findViewById(R.id.toggleMicrophone)

        checkPermissions()
    }

    private fun checkPermissions() {
        // Check whether permissions have been granted.
        // If not, ask for permissions
        val appContext: Context = applicationContext

        // Get the requested permissions safely
        val packageInfo = appContext.packageManager.getPackageInfo(
            appContext.packageName,
            PackageManager.GET_PERMISSIONS
        )

        // Handle potential null value with safe operator and empty array fallback
        val permissionList: Array<String> = packageInfo.requestedPermissions ?: emptyArray()

        val notGrantedPermissions: MutableList<String> = ArrayList()
        for (permission in permissionList) {
            if (ContextCompat.checkSelfPermission(appContext, permission)
                != PackageManager.PERMISSION_GRANTED) {
                notGrantedPermissions.add(permission)
            }
        }

        if (notGrantedPermissions.isNotEmpty()) {
            requestPermissionLauncher.launch(notGrantedPermissions.toTypedArray())
        } else {
            // Permission is granted, we can initialize the call
            initializeCallClient()
        }
    }
    private fun initializeCallClient() {
        // Create call client
        val call = CallClient(applicationContext)

        // Create map of video views
        val videoViews = mutableMapOf<ParticipantId, VideoView>()

        val layout = findViewById<LinearLayout>(R.id.videoLinearLayout)

        // Listen for events
        call.addListener(object : CallClientListener {
            // Handle a remote participant joining
            override fun onParticipantJoined(participant: Participant) {
                val participantView = layoutInflater.inflate(R.layout.participant_view, layout, false)

                val videoView = participantView.findViewById<VideoView>(R.id.participant_video)
                videoView.track = participant.media?.camera?.track
                videoViews[participant.id] = videoView

                layout.addView(participantView)
            }

            // Handle a participant updating (e.g. their tracks changing)
            override fun onParticipantUpdated(participant: Participant) {
                val videoView = videoViews[participant.id]
                videoView?.track = participant.media?.camera?.track
            }

            // Handle local input settings being updated
            override fun onInputsUpdated(inputSettings: InputSettings) {
                toggleCamera.isChecked = inputSettings.camera.isEnabled
                toggleMicrophone.isChecked = inputSettings.microphone.isEnabled
            }
        })

        // Set up toggle buttons
        toggleMicrophone.setOnCheckedChangeListener { _, isChecked ->
            Log.d(TAG, "User tapped the Mute button")
            call.setInputEnabled(OutboundMediaType.Microphone, isChecked)
        }

        toggleCamera.setOnCheckedChangeListener { _, isChecked ->
            Log.d(TAG, "User tapped the Cam button")
            call.setInputEnabled(OutboundMediaType.Camera, isChecked)
        }

        // Set up leave button
        findViewById<Button>(R.id.leave).setOnClickListener {
            Log.d(TAG, "User tapped the Leave button")
            call.leave {
                it.error?.apply {
                    Log.e(TAG, "Got error while leaving call: $msg")
                } ?: run {
                    Log.d(TAG, "Successfully left call")
                    finish() // Return to previous activity
                }
            }
        }

        // Join the call
        call.join(url = DAILY_ROOM_URL) {
            it.error?.apply {
                Log.e(TAG, "Got error while joining call: $msg")
            }
            it.success?.apply {
                Log.i(TAG, "Successfully joined call.")
                toggleCamera.isChecked = call.inputs().camera.isEnabled
                toggleMicrophone.isChecked = call.inputs().microphone.isEnabled
            }
        }
    }
}