package com.example.videocallapp.ui.registration

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.example.videocallapp.databinding.FragmentRegistrationStep1Binding

class RegistrationStep1Fragment : Fragment() {
    private var _binding: FragmentRegistrationStep1Binding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentRegistrationStep1Binding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Change btnRegister to btnNext to match your layout
        binding.btnNext.setOnClickListener {
            val info = binding.editTextStep1.text.toString().trim()

            if (info.isEmpty()) {
                Toast.makeText(context, "Please enter information before proceeding", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            Log.d("Registration", "User entered: $info")

            // Call the method in the activity to complete registration
            val activity = activity
            if (activity is RegistrationActivity) {
                activity.completeRegistration(info)
            } else {
                Log.e("Registration", "Activity is null or not RegistrationActivity")
                Toast.makeText(context, "Error completing registration", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}