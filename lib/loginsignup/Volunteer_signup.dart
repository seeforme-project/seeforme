import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../home/volunteer_dashboard.dart';
import '../globals/theme.dart';

class VolunteerSignupScreen extends StatefulWidget {
  const VolunteerSignupScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerSignupScreen> createState() => _VolunteerSignupScreenState();
}

class _VolunteerSignupScreenState extends State<VolunteerSignupScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final Set<int> _selectedTimeSlots = {};

  final String currentDateTime = "2025-03-08 18:58:40";
  final String userLogin = "mujtaba-io";

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final startHour = index * 2;
        final endHour = (index * 2 + 2) % 24;
        final isSelected = _selectedTimeSlots.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTimeSlots.remove(index);
              } else {
                _selectedTimeSlots.add(index);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? RosePineColors.pine : RosePineColors.overlay,
              border: Border.all(
                color: RosePineColors.muted,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${startHour.toString().padLeft(2, '0')}-${endHour.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color:
                      isSelected ? RosePineColors.text : RosePineColors.subtle,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: RosePineColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: RosePineColors.muted,
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: RosePineColors.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: RosePineColors.subtle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.addressBook,
                  color: RosePineColors.iris,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    color: RosePineColors.iris,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'We\'ll use these details to connect you with people who need assistance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RosePineColors.subtle,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RosePineColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RosePineColors.muted,
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.shieldHalved,
                    color: RosePineColors.rose,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your contact information is secure and will only be shared with verified users',
                      style: TextStyle(
                        color: RosePineColors.subtle,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.userCircle,
                  color: RosePineColors.iris,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Personal Details',
                  style: TextStyle(
                    color: RosePineColors.iris,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Let others know who their helper is',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RosePineColors.subtle,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            _buildInputField(
              label: 'Full Name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RosePineColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RosePineColors.muted,
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: RosePineColors.foam,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your name will be displayed to users who need assistance',
                      style: TextStyle(
                        color: RosePineColors.subtle,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.clock,
                  color: RosePineColors.iris,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Availability Schedule',
                  style: TextStyle(
                    color: RosePineColors.iris,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Select the time slots when you\'re available to help',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RosePineColors.subtle,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            _buildTimeSlots(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RosePineColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RosePineColors.muted,
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.bell,
                    color: RosePineColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'ll receive notifications only during your selected time slots',
                      style: TextStyle(
                        color: RosePineColors.subtle,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepIndicator(int step, String title) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? RosePineColors.pine : RosePineColors.surface,
              border: Border.all(
                color: RosePineColors.muted,
                width: 2,
              ),
            ),
            child: Center(
              child: isCurrent
                  ? FaIcon(
                      FontAwesomeIcons.angleDown,
                      color: RosePineColors.text,
                      size: 18,
                    )
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive
                            ? RosePineColors.text
                            : RosePineColors.subtle,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? RosePineColors.iris : RosePineColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RosePineColors.base,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: RosePineColors.iris,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Volunteer Signup',
          style: TextStyle(
            color: RosePineColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Contact'),
                _buildStepConnector(),
                _buildStepIndicator(1, 'Personal'),
                _buildStepConnector(),
                _buildStepIndicator(2, 'Schedule'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 30,
      height: 2,
      color: RosePineColors.muted,
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RosePineColors.base,
        boxShadow: [
          BoxShadow(
            color: RosePineColors.base.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentStep == 2
                ? 'Ready to help others see the world?'
                : 'Step ${_currentStep + 1} of 3',
            style: TextStyle(
              color: RosePineColors.iris,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _currentStep--);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RosePineColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: RosePineColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      // Handle form submission
                      print('Phone: ${_phoneController.text}');
                      print('Email: ${_emailController.text}');
                      print('Name: ${_nameController.text}');
                      print('Selected time slots: $_selectedTimeSlots');

                      // for now, goto volunteer dashboard
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VolunteerDashboardScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RosePineColors.pine,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentStep == 2 ? 'Start Helping' : 'Next',
                    style: TextStyle(
                      color: RosePineColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
