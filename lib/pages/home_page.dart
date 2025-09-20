import 'package:flutter/material.dart';

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  bool _isAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 2,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFFF3F4F6),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset, color: Color(0xFFF3F4F6)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFFF3F4F6)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF374151), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAvailable = !_isAvailable;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: _isAvailable
                        ? const Color(0xFF059669)
                        : const Color(0xFF4B5563),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAvailable ? Icons.check_circle : Icons.power_off,
                        size: 40,
                        color: const Color(0xFFF3F4F6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                        style: const TextStyle(
                          color: Color(0xFFF3F4F6),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Pending Assistance Calls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF3F4F6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for IncomingCallsList
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF374151)),
              ),
              child: const Center(
                child: Text(
                  'Incoming calls will be displayed here',
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nearby Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF3F4F6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF374151), width: 1),
              ),
              child: const Center(
                child: Text(
                  'Map will be displayed here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
