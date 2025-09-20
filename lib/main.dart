import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_call_app/join_screen.dart';
import 'package:video_call_app/pages/welcome_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VideoSDK Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: JoinScreen(),
    );
  }
}
