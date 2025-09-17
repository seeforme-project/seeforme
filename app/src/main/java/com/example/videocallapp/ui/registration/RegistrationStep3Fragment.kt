//package com.example.videocallapp.ui.registration
//
//import android.os.Bundle
//import android.view.LayoutInflater
//import android.view.View
//import android.view.ViewGroup
//import androidx.fragment.app.Fragment
//import com.example.videocallapp.R
//import com.example.videocallapp.databinding.FragmentRegistrationStep1Binding
//
//class RegistrationStep3Fragment : Fragment() {
//    private var _binding: FragmentRegistrationStep1Binding? = null
//    private val binding get() = _binding!!
//    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
//        _binding = FragmentRegistrationStep1Binding.inflate(inflater, container, false)
//        return binding.root
//    }
//    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
//        binding.btnNext.setOnClickListener {
//            // Save name/email/phone/password/gender to ViewModel or Bundle
//            // Then go to next step
//            parentFragmentManager.beginTransaction()
//                .replace(R.id.registration_container, RegistrationStep2Fragment())
//                .addToBackStack(null)
//                .commit()
//        }
//    }
//    override fun onDestroyView() {
//        super.onDestroyView()
//        _binding = null
//    }
//}