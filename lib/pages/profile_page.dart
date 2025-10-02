// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:seeforme/pages/volunteer_login_page.dart';
import 'package:seeforme/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();

  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final userData = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _userName = userData['name'] ?? 'No name found';
          _userEmail = userData['email'] ?? 'No email found';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const VolunteerLoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF1F2937),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- User Information Display ---
            _buildInfoTile(icon: Icons.person_outline, label: 'Name', value: _userName),
            const SizedBox(height: 20),
            _buildInfoTile(icon: Icons.email_outlined, label: 'Email', value: _userEmail),

            const Spacer(), // Pushes the logout button to the bottom

            // --- Logout Button ---
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF374151))
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }
}