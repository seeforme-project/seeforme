// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


class TokenStorage {
  static String? _accessToken;
  static String? _refreshToken;
  static String? _userId; // ADDED: To store the user's ID

  static Future<void> saveTokensAndUser({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
  }

  static Future<String?> getAccessToken() async => _accessToken;
  static Future<String?> getUserId() async => _userId; // ADDED: Getter for user ID

  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
  }
}


class AuthService {
  static const String _baseUrl = 'https://mujtaba-io-seeforme.hf.space';

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    final url = Uri.parse('$_baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'account_type': accountType,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseBody = jsonDecode(response.body);

      // 201 Created is the success code from your API doc
      if (response.statusCode == 201) {
        print('Signup successful: $responseBody');
        return responseBody; // Return the full response
      } else {
        // Handle server-side validation errors
        throw Exception(responseBody['error'] ?? 'An unknown error occurred.');
      }
    } on TimeoutException {
      // Handle network timeout
      throw Exception('The server took too long to respond. Please try again.');
    } catch (e) {
      // Handle other exceptions (e.g., no internet, DNS error)
      print('An error occurred during signup: $e');
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  // --- LOGIN METHOD ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Login successful: $responseBody');
        return responseBody;
      } else {
        // Handle server-side errors (e.g., invalid credentials)
        throw Exception(responseBody['error'] ?? 'An unknown error occurred.');
      }
    } on TimeoutException {
      throw Exception('The server took too long to respond. Please try again.');
    } catch (e) {
      print('An error occurred during login: $e');
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  Future<Map<String, dynamic>> updateProfile({required String name}) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Not authenticated.');

    final url = Uri.parse('$_baseUrl/profile');
    try {
      final response = await http.put( // Using PUT as specified
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      ).timeout(const Duration(seconds: 15));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['user'];
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to update profile.');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server.');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('Your session has expired. Please log in again.');

    final url = Uri.parse('$_baseUrl/profile');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['user'];
      } else {
        throw Exception(responseBody['error'] ?? 'Failed to load profile.');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server.');
    }
  }

  // --- LOGOUT METHOD ---
  Future<void> logout() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return;

    final url = Uri.parse('$_baseUrl/logout');
    try {
      await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
    } finally {
      // ALWAYS clear tokens on logout
      await TokenStorage.clearTokens();
    }
  }
}