import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_call_app/meeting_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_call.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _nameController = TextEditingController();
  final _meetingIdController = TextEditingController();
  final String? token = dotenv.env['AUTH_TOKEN'];

  @override
  void dispose() {
    _nameController.dispose();
    _meetingIdController.dispose();
    super.dispose();
  }

  void navigateToMeeting(String meetingId, String displayName) {
    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingScreen(
          meetingId: meetingId,
          token: token!,
          displayName: displayName,
        ),
      ),
    );
  }

  void onCreateButtonPressed() async {
    var statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses[Permission.camera]!.isGranted && statuses[Permission.microphone]!.isGranted) {
      try {
        final meetingId = await createMeeting();
        final displayName = _nameController.text.trim();
        navigateToMeeting(meetingId, displayName);
      } catch (e) {
        print("Error creating meeting: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create a meeting.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera and Mic permissions are required.")),
      );
    }
  }

  void onJoinButtonPressed() {
    String meetingId = _meetingIdController.text.trim();
    final displayName = _nameController.text.trim();

    if (meetingId.isNotEmpty) {
      navigateToMeeting(meetingId, displayName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid meeting ID")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoSDK Quick Start'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCreateButtonPressed,
              child: const Text('Create Meeting'),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _meetingIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Meeting ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onJoinButtonPressed,
              child: const Text('Join Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}