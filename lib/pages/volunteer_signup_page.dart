// lib/pages/volunteer_signup_page.dart

import 'package:flutter/material.dart';
import 'package:seeforme/pages/volunteer_login_page.dart';
import 'package:seeforme/services/auth_service.dart';

class VolunteerSignupPage extends StatefulWidget {
  const VolunteerSignupPage({super.key});

  @override
  State<VolunteerSignupPage> createState() => _VolunteerSignupPageState();
}

class _VolunteerSignupPageState extends State<VolunteerSignupPage> {
  int _currentStep = 0;

  // Form Keys to manage validation for each step
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKeyStep1.currentState!.validate() ||
        !_formKeyStep2.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        accountType: 'volunteer',
      );

      // ✅ Extract tokens & userId
      final accessToken = response['access_token'];
      final refreshToken = response['refresh_token'];
      final userId = response['user']?['id'] ?? response['id'];

      if (accessToken != null && refreshToken != null && userId != null) {
        await TokenStorage.saveTokensAndUser(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId.toString(),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Account created successfully! Please log in."),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const VolunteerLoginPage()),
            (Route<dynamic> route) => false,
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

  void _onStepContinue() {
    bool isStepValid = false;
    switch (_currentStep) {
      case 0:
        if (_formKeyStep1.currentState!.validate()) {
          isStepValid = true;
        }
        break;
      case 1:
        if (_formKeyStep2.currentState!.validate()) {
          isStepValid = true;
        }
        break;
      case 2:
        _handleSignup();
        return;
    }

    if (isStepValid) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF3F4F6)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volunteer Registration',
              style: TextStyle(
                  color: Color(0xFFF3F4F6),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Join our community of helpers',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF374151), height: 1.0),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _isLoading ? null : _onStepContinue,
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Account',
                style: TextStyle(color: Color(0xFFF3F4F6))),
            content: Form(
              key: _formKeyStep1,
              child: Column(
                children: [
                  _buildOutlinedCard(
                    icon: Icons.account_circle,
                    title: 'Personal Information',
                    description:
                    'We use this information to create your volunteer profile.',
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                    _inputDecoration('Full Name', icon: Icons.account_circle),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildOutlinedCard(
                    icon: Icons.email,
                    title: 'Contact Details',
                    description:
                    'Your email will be used for account verification.',
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                    _inputDecoration('Email Address', icon: Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address.';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Security',
                style: TextStyle(color: Color(0xFFF3F4F6))),
            content: Form(
              key: _formKeyStep2,
              child: Column(
                children: [
                  _buildOutlinedCard(
                    icon: Icons.lock,
                    title: 'Account Security',
                    description: 'Create a strong password for better security.',
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                    _inputDecoration('Password', icon: Icons.lock),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password.';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Confirm Password',
                        icon: Icons.lock),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password.';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Confirm',
                style: TextStyle(color: Color(0xFFF3F4F6))),
            content: Column(
              children: [
                _buildOutlinedCard(
                  icon: Icons.check_circle,
                  title: 'Ready to Join',
                  description:
                  "Review your information before creating your volunteer account.",
                  color: const Color(0xFF4F46E5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle,
                          size: 60, color: Color(0xFF4F46E5)),
                      SizedBox(height: 16),
                      Text(
                        'Account Review',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF3F4F6)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Press 'Create Account' to complete your registration",
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF9CA3AF)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading && _currentStep == 2
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    )
                        : Text(
                      _currentStep == 2 ? 'Create Account' : 'Next',
                      style: const TextStyle(color: Color(0xFFF3F4F6)),
                    ),
                  ),
                ),
                if (_currentStep != 0) const SizedBox(width: 10),
                if (_currentStep != 0)
                  Expanded(
                    child: TextButton(
                      onPressed: details.onStepCancel,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side:
                          const BorderSide(color: Color(0xFFF3F4F6)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back',
                          style: TextStyle(color: Color(0xFFF3F4F6))),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOutlinedCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      prefixIcon:
      icon != null ? Icon(icon, color: const Color(0xFF9CA3AF)) : null,
      filled: true,
      fillColor: const Color(0xFF1F2937),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF4F46E5)),
      ),
    );
  }
}
