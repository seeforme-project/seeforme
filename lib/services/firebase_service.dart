// lib/services/firebase_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  late DatabaseReference _callsRef;

  FirebaseService() {
    // Reference to the 'incoming_calls' list in your Realtime Database
    _callsRef = _database.ref('incoming_calls');
  }

  // --- Firestore & FCM Methods (for Volunteer Status) ---

  Future<void> initializeForVolunteer(String userId) async {
    await _messaging.requestPermission();
    final fcmToken = await _messaging.getToken();

    if (fcmToken != null) {
      await _firestore.collection('volunteers').doc(userId).set({
        'fcmToken': fcmToken,
        'isAvailable': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateAvailability(String userId, bool isAvailable) async {
    await _firestore.collection('volunteers').doc(userId).update({
      'isAvailable': isAvailable,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // --- Realtime Database Methods (for Live Call Requests) ---

  /// Adds a new call request to the Realtime Database.
  /// Returns the unique key for the call entry.
  Future<String> addCallRequest(String meetingId) async {
    final newCallRef = _callsRef.push();
    await newCallRef.set({
      'meetingId': meetingId,
      'timestamp': ServerValue.timestamp,
    });
    return newCallRef.key!;
  }

  /// Listens for a specific call to be removed from the database.
  /// Used by the blind user to know when a volunteer has answered.
  Stream<DatabaseEvent> listenForCallAcceptance(String callId) {
    return _callsRef.child(callId).onValue;
  }

  /// Gets a stream of all incoming call requests.
  /// Used by volunteers to see the dashboard list.
  Stream<DatabaseEvent> getIncomingCallsStream() {
    return _callsRef.onValue;
  }

  /// Removes a call from the database when a volunteer answers it.
  Future<void> answerCall(String callId) async {
    await _callsRef.child(callId).remove();
  }
}
