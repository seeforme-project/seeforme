// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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
}