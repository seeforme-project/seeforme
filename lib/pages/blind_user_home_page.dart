// lib/pages/blind_user_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeforme/api_call.dart';
import 'package:seeforme/liveai/session_cubit.dart';
import 'package:seeforme/liveai/session_page.dart';
import 'package:seeforme/meeting_screen.dart';
import 'package:seeforme/services/cloud_functions_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class BlindUserHomePage extends StatefulWidget {
  const BlindUserHomePage({super.key});

  @override
  State<BlindUserHomePage> createState() => _BlindUserHomePageState();
}

class _BlindUserHomePageState extends State<BlindUserHomePage> {
  bool _isCalling = false;
  final _functionsService = CloudFunctionsService();

  Future<void> _initiateCall() async {
    setState(() {
      _isCalling = true;
    });

    try {
      // 1. Create a VideoSDK meeting room
      final meetingId = await createMeeting();

      // 2. Call our Firebase Cloud Function to find and notify a volunteer
      await _functionsService.findVolunteerAndNotify(meetingId: meetingId);

      // 3. Get the VideoSDK JWT Token from your .env file
      final videoSdkToken = dotenv.env['AUTH_TOKEN'];
      if (videoSdkToken == null) {
        throw Exception("VideoSDK Token not found in .env file.");
      }

      // 4. Automatically navigate to the meeting screen
      // Use pushReplacement to prevent user from going back to this page during a call
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MeetingScreen(
            meetingId: meetingId,
            token: videoSdkToken,
            displayName: "User in Need",
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.orangeAccent, content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('See for Me'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Button for AI Assistance
              ElevatedButton.icon(
                onPressed: _isCalling ? null : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => SessionCubit(),
                        child: const SessionPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.smart_toy_outlined, size: 28),
                label: const Text('AI Assistance'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              // Button for calling a human volunteer
              ElevatedButton.icon(
                onPressed: _isCalling ? null : _initiateCall,
                icon: const Icon(Icons.video_call_outlined, size: 28),
                label: _isCalling
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    ),
                    SizedBox(width: 24),
                    Text("Calling..."),
                  ],
                )
                    : const Text('Call a Volunteer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}