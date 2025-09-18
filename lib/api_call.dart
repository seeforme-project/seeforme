import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final String? authToken = dotenv.env['AUTH_TOKEN'];

Future<String> createMeeting() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': authToken!},
  );


  if (httpResponse.statusCode == 200) {
    return json.decode(httpResponse.body)['roomId'];
  } else {
    print("-----------------------------------------");
    print("API CALL FAILED");
    print("Status Code: ${httpResponse.statusCode}");
    print("Response Body: ${httpResponse.body}");
    print("-----------------------------------------");
    throw Exception("Failed to create meeting. See logs for details.");
  }
}