import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../globals/theme.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  bool _isAvailable = false;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  // Mock data for blind people needing assistance
  final List<BlindPerson> _pendingAssistance = [
    BlindPerson(
      id: '1',
      name: 'John Doe',
      distance: '0.5',
      location: const LatLng(37.7749, -122.4194),
      urgency: Urgency.high,
      timeRequested: '5 minutes ago',
      description: 'Need help crossing busy intersection',
    ),
    BlindPerson(
      id: '2',
      name: 'Jane Smith',
      distance: '1.2',
      location: const LatLng(37.7749, -122.4294),
      urgency: Urgency.medium,
      timeRequested: '10 minutes ago',
      description: 'Assistance needed with reading menu at restaurant',
    ),
  ];

  @override
  void initState() {
    super.initState();
    for (var person in _pendingAssistance) {
      _markers.add(
        Marker(
          markerId: MarkerId(person.id),
          position: person.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            person.urgency == Urgency.high
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: RosePineColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RosePineColors.muted,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.solidClock,
                color: RosePineColors.iris,
                size: 12,
              ),
              const SizedBox(width: 6),
              Text(
                "2025-03-08 19:03:37",
                style: TextStyle(
                  fontSize: 12,
                  color: RosePineColors.iris,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: RosePineColors.muted,
          ),
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.solidUser,
                color: RosePineColors.iris,
                size: 12,
              ),
              const SizedBox(width: 6),
              Text(
                "mujtaba-io",
                style: TextStyle(
                  fontSize: 12,
                  color: RosePineColors.iris,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isAvailable = !_isAvailable;
            });
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  _isAvailable ? RosePineColors.pine : RosePineColors.surface,
              border: Border.all(
                color: RosePineColors.muted,
                width: 3,
              ),
              boxShadow: _isAvailable
                  ? [
                      BoxShadow(
                        color: RosePineColors.pine.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  _isAvailable
                      ? FontAwesomeIcons.handHoldingHeart
                      : FontAwesomeIcons.powerOff,
                  size: 40,
                  color: _isAvailable
                      ? RosePineColors.text
                      : RosePineColors.subtle,
                ),
                const SizedBox(height: 12),
                Text(
                  _isAvailable ? "I'm Available" : "Go Available",
                  style: TextStyle(
                    color: _isAvailable
                        ? RosePineColors.text
                        : RosePineColors.subtle,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isAvailable
              ? "You're currently available to help"
              : "Toggle to start helping others",
          style: TextStyle(
            color: RosePineColors.subtle,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingAssistanceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            "Pending Assistance Requests",
            style: TextStyle(
              color: RosePineColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingAssistance.length,
          itemBuilder: (context, index) {
            final person = _pendingAssistance[index];
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: RosePineColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: RosePineColors.muted,
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: person.urgency == Urgency.high
                        ? RosePineColors.love.withOpacity(0.2)
                        : RosePineColors.gold.withOpacity(0.2),
                  ),
                  child: Center(
                    child: FaIcon(
                      person.urgency == Urgency.high
                          ? FontAwesomeIcons.exclamation
                          : FontAwesomeIcons.clock,
                      color: person.urgency == Urgency.high
                          ? RosePineColors.love
                          : RosePineColors.gold,
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  person.name,
                  style: TextStyle(
                    color: RosePineColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      person.description,
                      style: TextStyle(
                        color: RosePineColors.subtle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 12,
                          color: RosePineColors.foam,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${person.distance} km away',
                          style: TextStyle(
                            color: RosePineColors.foam,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FaIcon(
                          FontAwesomeIcons.clock,
                          size: 12,
                          color: RosePineColors.rose,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          person.timeRequested,
                          style: TextStyle(
                            color: RosePineColors.rose,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.angleRight,
                    color: RosePineColors.subtle,
                  ),
                  onPressed: () {
                    // Handle assistance request
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            "Emergency Assistance Map",
            style: TextStyle(
              color: RosePineColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: RosePineColors.muted,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                // You can customize map style here to match Rosé Pine Dark theme
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RosePineColors.base,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 30),
              _buildAvailabilityToggle(),
              const SizedBox(height: 30),
              _buildPendingAssistanceList(),
              const SizedBox(height: 30),
              _buildEmergencyMap(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

enum Urgency { high, medium, low }

class BlindPerson {
  final String id;
  final String name;
  final String distance;
  final LatLng location;
  final Urgency urgency;
  final String timeRequested;
  final String description;

  BlindPerson({
    required this.id,
    required this.name,
    required this.distance,
    required this.location,
    required this.urgency,
    required this.timeRequested,
    required this.description,
  });
}
