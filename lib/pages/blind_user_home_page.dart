// lib/pages/blind_user_home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeforme/api_call.dart';
import 'package:seeforme/liveai/session_cubit.dart';
import 'package:seeforme/liveai/session_page.dart';
import 'package:seeforme/meeting_screen.dart';
import 'package:seeforme/services/firebase_service.dart'; // UPDATED import
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BlindUserHomePage extends StatefulWidget {
  const BlindUserHomePage({super.key});

  @override
  State<BlindUserHomePage> createState() => _BlindUserHomePageState();
}

class _BlindUserHomePageState extends State<BlindUserHomePage> {
  bool _isCalling = false;
  final _firebaseService = FirebaseService();
  StreamSubscription? _callSubscription;

  @override
  void dispose() {
    // Ensure we cancel the listener if the user leaves the page.
    _callSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initiateCall() async {
    setState(() {
      _isCalling = true;
    });

    try {
      // 1. Create a VideoSDK meeting room
      final meetingId = await createMeeting();
      final videoSdkToken = dotenv.env['AUTH_TOKEN'];
      if (videoSdkToken == null) {
        throw Exception("VideoSDK Token not found in .env file.");
      }

      // 2. Add call request to Realtime DB and get its unique key
      final callId = await _firebaseService.addCallRequest(meetingId);

      // 3. Listen for the call to be accepted (i.e., removed from the DB)
      _callSubscription = _firebaseService.listenForCallAcceptance(callId).listen((
        event,
      ) {
        // When snapshot.exists is false, it means the entry was removed (answered)
        if (!event.snapshot.exists) {
          _callSubscription?.cancel(); // Stop listening
          if (!mounted) return;

          // 4. Navigate to the meeting screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MeetingScreen(
                meetingId: meetingId,
                token: videoSdkToken,
                displayName: "User in Need",
              ),
            ),
          );
        }
      });

      // 5. Timeout: if no one answers in 60 seconds, cancel the request.
      Future.delayed(const Duration(seconds: 60), () {
        if (mounted && _isCalling) {
          _callSubscription?.cancel();
          _firebaseService.answerCall(callId); // Clean up the orphaned request
          setState(() {
            _isCalling = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "No volunteer was available. Please try again later.",
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
        );
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
                onPressed: _isCalling
                    ? null
                    : () {
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
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(width: 24),
                          Text("Calling Volunteer..."),
                        ],
                      )
                    : const Text('Call a Volunteer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 70),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
