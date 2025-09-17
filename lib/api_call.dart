import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final String? authToken = dotenv.env['AUTH_TOKEN'];

Future<String> createMeeting() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': authToken!},
  );

  print("Create Meeting API Response Status Code: ${httpResponse.statusCode}");
  print("Create Meeting API Response Body: ${httpResponse.body}");

  if (httpResponse.statusCode == 200) {
    return json.decode(httpResponse.body)['roomId'];
  } else {
    throw Exception("Failed to create meeting: ${httpResponse.body}");
  }
}