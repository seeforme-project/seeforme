import 'package:flutter/material.dart';
import 'package:video_call_app/meeting_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_call.dart';


class JoinScreen extends StatelessWidget {
  final _meetingIdController = TextEditingController();
  final String? authToken = dotenv.env['AUTH_TOKEN'];

  JoinScreen({super.key});

  void onCreateButtonPressed(BuildContext context) async {
    try {
      print("Attempting to create a new meeting...");
      final meetingId = await createMeeting();
      print("Meeting created successfully! Meeting ID: $meetingId");

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingScreen(
              meetingId: meetingId,
              token: authToken!,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error creating meeting: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to create a meeting. Please check the logs.")),
        );
      }
    }
  }


  void onJoinButtonPressed(BuildContext context) {
    String meetingId = _meetingIdController.text;
    if (meetingId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeetingScreen(
            meetingId: meetingId,
            token: authToken!,
          ),
        ),
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
            ElevatedButton(
              onPressed: () => onCreateButtonPressed(context),
              child: const Text('Create Meeting'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _meetingIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Meeting ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onJoinButtonPressed(context),
              child: const Text('Join Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}