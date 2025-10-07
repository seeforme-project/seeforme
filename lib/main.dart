// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seeforme/pages/welcome_page.dart'; // Make sure this path is correct

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // This is needed for the VideoSDK API key
  await dotenv.load(fileName: ".env");
  runApp(const SeeForMeApp());
}

class SeeForMeApp extends StatelessWidget {
  const SeeForMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'See for Me',
      // We can define a consistent dark theme for the whole app here
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827),
        primaryColor: const Color(0xFF4F46E5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: const Color.fromARGB(255, 19, 9, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // The WelcomePage is the very first screen of the application
      home: const WelcomePage(),
    );
  }
}
