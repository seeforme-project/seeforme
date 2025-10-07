// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:seeforme/meeting_screen.dart';
import 'package:seeforme/pages/profile_page.dart';
import 'package:seeforme/services/auth_service.dart';
import 'package:seeforme/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timeago/timeago.dart' as timeago;

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  final _firebaseService = FirebaseService();
  bool _isAvailable = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndInitFirebase();
  }

  Future<void> _loadUserIdAndInitFirebase() async {
    final userId = await TokenStorage.getUserId();
    if (userId != null) {
      setState(() {
        _currentUserId = userId;
      });
      await _firebaseService.initializeForVolunteer(userId);
    } else {
      print("Error: User ID not found. Cannot initialize Firebase services.");
    }
  }

  Future<void> _toggleAvailability() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not identify user. Please log in again."),
        ),
      );
      return;
    }
    final newAvailability = !_isAvailable;
    setState(() {
      _isAvailable = newAvailability;
    });
    try {
      await _firebaseService.updateAvailability(
        _currentUserId!,
        newAvailability,
      );
    } catch (e) {
      setState(() {
        _isAvailable = !newAvailability;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update status: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 2,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFFF3F4F6),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFFF3F4F6)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF374151), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _toggleAvailability,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: _isAvailable
                        ? const Color(0xFF059669)
                        : const Color(0xFF4B5563),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAvailable ? Icons.check_circle : Icons.power_off,
                        size: 40,
                        color: const Color(0xFFF3F4F6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                        style: const TextStyle(
                          color: Color(0xFFF3F4F6),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Pending Assistance Calls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF3F4F6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // --- NEW REALTIME CALL LIST ---
            Container(
              constraints: const BoxConstraints(minHeight: 100, maxHeight: 300),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<DatabaseEvent>(
                stream: _firebaseService.getIncomingCallsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Text(
                        'No incoming calls right now',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    );
                  }

                  // Data exists, parse it into a list
                  final callsData = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );
                  final calls = callsData.entries.toList();
                  // Sort by timestamp, newest first
                  calls.sort(
                    (a, b) => (b.value['timestamp'] as int).compareTo(
                      a.value['timestamp'] as int,
                    ),
                  );

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: calls.length,
                    itemBuilder: (context, index) {
                      final callEntry = calls[index];
                      final callId = callEntry.key;

                      final callDetails = Map<String, dynamic>.from(
                        callEntry.value,
                      );
                      final meetingId = callDetails['meetingId'] as String;
                      final timestamp = DateTime.fromMillisecondsSinceEpoch(
                        callDetails['timestamp'] as int,
                      );

                      return ListTile(
                        leading: const Icon(
                          Icons.ring_volume,
                          color: Color(0xFF4F46E5),
                        ),
                        title: Text(
                          'Incoming Call',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          timeago.format(timestamp),
                          style: const TextStyle(color: Color(0xFF9CA3AF)),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                          ),
                          child: const Text('Answer'),
                          onPressed: () async {
                            try {
                              final videoSdkToken = dotenv.env['AUTH_TOKEN'];
                              if (videoSdkToken == null) {
                                throw Exception("VideoSDK Token not found.");
                              }

                              // 1. Navigate to the meeting screen BEFORE awaiting the database change.
                              // This ensures the BuildContext is valid and avoids the race condition.
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MeetingScreen(
                                    meetingId: meetingId,
                                    token: videoSdkToken,
                                    displayName: "Volunteer",
                                  ),
                                ),
                              );

                              // 2. AFTER initiating navigation, remove the call from DB to claim it.
                              // This notifies the blind user and updates the list for other volunteers.
                              await _firebaseService.answerCall(callId);
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to answer call: $e"),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
