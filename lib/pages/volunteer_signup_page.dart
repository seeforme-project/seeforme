import 'package:flutter/material.dart';
import 'home_page.dart';

class VolunteerSignupPage extends StatefulWidget {
  const VolunteerSignupPage({super.key});

  @override
  State<VolunteerSignupPage> createState() => _VolunteerSignupPageState();
}

class _VolunteerSignupPageState extends State<VolunteerSignupPage> {
  int _currentStep = 0;

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
                fontWeight: FontWeight.bold,
              ),
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
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else if (_currentStep == 2) {
            // Navigate to the home page when the final step's "Create Account" button is pressed
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const VolunteerHomePage(),
              ),
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text(
              'Account',
              style: TextStyle(color: Color(0xFFF3F4F6)),
            ),
            content: Column(
              children: [
                _buildOutlinedCard(
                  icon: Icons.account_circle,
                  title: 'Personal Information',
                  description:
                      'We use this information to create your volunteer profile and verify your identity.',
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: _inputDecoration(
                    'Full Name',
                    icon: Icons.account_circle,
                  ),
                ),
                const SizedBox(height: 20),
                _buildOutlinedCard(
                  icon: Icons.email,
                  title: 'Contact Details',
                  description:
                      'Your email will be used for account verification and important communications.',
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: _inputDecoration(
                    'Email Address',
                    icon: Icons.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text(
              'Security',
              style: TextStyle(color: Color(0xFFF3F4F6)),
            ),
            content: Column(
              children: [
                _buildOutlinedCard(
                  icon: Icons.lock,
                  title: 'Account Security',
                  description:
                      'Create a strong password that includes letters, numbers, and special characters for better security.',
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: _inputDecoration('Password', icon: Icons.lock),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: _inputDecoration(
                    'Confirm Password',
                    icon: Icons.lock,
                  ),
                  obscureText: true,
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text(
              'Confirm',
              style: TextStyle(color: Color(0xFFF3F4F6)),
            ),
            content: Column(
              children: [
                _buildOutlinedCard(
                  icon: Icons.check_circle,
                  title: 'Ready to Join',
                  description:
                      "Review your information before creating your volunteer account. Thank you for choosing to make a difference.",
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
                      Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Color(0xFF4F46E5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Account Review',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF3F4F6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Press 'Create Account' to complete your registration",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
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
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
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
                          side: const BorderSide(color: Color(0xFFF3F4F6)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Color(0xFFF3F4F6)),
                      ),
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
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
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF9CA3AF))
          : null,
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
