import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  final _functions = FirebaseFunctions.instance;

  Future<void> findVolunteerAndNotify({required String meetingId}) async {
    try {
      final callable = _functions.httpsCallable('findVolunteerAndNotify');
      final result = await callable.call({'meetingId': meetingId});
      print("Cloud function result: ${result.data}");
    } on FirebaseFunctionsException catch (e) {
      print("Cloud function error: ${e.code} - ${e.message}");
      // Re-throw the error with a user-friendly message
      throw Exception(e.message ?? "An error occurred while finding a volunteer.");
    }
  }
}