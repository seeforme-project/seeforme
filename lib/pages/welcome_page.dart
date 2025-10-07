import 'package:flutter/material.dart';
import 'package:seeforme/pages/volunteer_login_page.dart';
import 'package:seeforme/pages/volunteer_signup_page.dart';

import 'package:seeforme/liveai/session_cubit.dart';
import 'package:seeforme/liveai/session_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'CONNECTED',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,

                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text(
                'See for Me',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF3F4F6),
                  letterSpacing: 1,
                ),
              ),
              Container(
                width: 40,
                height: 2,
                color: const Color(0xFF4B5563),
                margin: const EdgeInsets.symmetric(vertical: 15),
              ),
              const Text(
                'Vision Assistance App',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1AFBBF24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BETA',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to VolunteerLogin
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VolunteerLoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(
                  Icons.handshake,
                  size: 22,
                  color: Colors.white,
                ),
                label: const Text(
                  'I am Volunteer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF374151), thickness: 1),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to the new BlindUserHomePage
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => SessionCubit(),
                        child: const SessionPage(),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF1F2937),
                ),
                icon: const Icon(Icons.mic, size: 22, color: Colors.white),
                label: const Text(
                  "say \"I'm blind\"",
                  style: TextStyle(
                    color: Color(0xFFF3F4F6),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Begin your journey',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
