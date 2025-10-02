// lib/pages/volunteer_login_page.dart

import 'package:flutter/material.dart';
import 'package:seeforme/pages/home_page.dart';
import 'package:seeforme/pages/volunteer_signup_page.dart';
import 'package:seeforme/services/auth_service.dart';

class VolunteerLoginPage extends StatefulWidget {
  const VolunteerLoginPage({super.key});

  @override
  State<VolunteerLoginPage> createState() => _VolunteerLoginPageState();
}

class _VolunteerLoginPageState extends State<VolunteerLoginPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ Extract tokens and userId from response
      final accessToken = response['access_token'];
      final refreshToken = response['refresh_token'];
      final userId = response['user']?['id'] ?? response['id']; // depends on API

      if (accessToken != null && refreshToken != null && userId != null) {
        await TokenStorage.saveTokensAndUser(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId.toString(),
        );
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VolunteerHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form( // Wrap in a Form for validation
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text('Welcome', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
                const SizedBox(height: 60),
                const Text('See for Me', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFFF3F4F6), letterSpacing: 1)),
                Container(width: 40, height: 2, color: const Color(0xFF374151), margin: const EdgeInsets.symmetric(vertical: 15)),
                const Text('Vision Assistance App', style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(color: const Color(0x1AFBBF24), borderRadius: BorderRadius.circular(12)),
                  child: const Text('BETA', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 40),
                const Text('Volunteer Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF3F4F6))),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Color(0xFFF3F4F6)),
                  decoration: _inputDecoration('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Color(0xFFF3F4F6)),
                  obscureText: !_showPassword,
                  decoration: _inputDecoration(
                    'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9CA3AF)),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Login', style: TextStyle(color: Color(0xFFF3F4F6), fontSize: 16, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFF374151))),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('OR', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, letterSpacing: 1))),
                    Expanded(child: Divider(color: Color(0xFF374151))),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const VolunteerSignupPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Create an Account', style: TextStyle(color: Color(0xFFF3F4F6), fontSize: 16, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFF1F2937),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFF374151))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFF4F46E5))),
      suffixIcon: suffixIcon,
    );
  }
}