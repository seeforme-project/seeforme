// lib/liveai/session_page.dart

// NEW: Import necessary packages for call logic
import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seeforme/api_call.dart';
import 'package:seeforme/liveai/session_cubit.dart';
import 'package:seeforme/meeting_screen.dart';
import 'package:seeforme/services/firebase_service.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with WidgetsBindingObserver {
  bool _showDebug = false;
  late TextEditingController _wsController;

  // NEW: State variables moved from the test page
  bool _isCalling = false;
  final _firebaseService = FirebaseService();
  StreamSubscription? _callSubscription;

  // NEW: Variables for triple-tap detection
  int _tapCount = 0;
  Timer? _tapTimer;

  @override
  void initState() {
    super.initState();
    _wsController = TextEditingController(text: WEBSOCKET_URL);
    context.read<SessionCubit>().startSession();
  }

  @override
  void dispose() {
    _wsController.dispose();
    context.read<SessionCubit>().stopSession();
    // NEW: Clean up the call listener and tap timer to prevent memory leaks
    _callSubscription?.cancel();
    _tapTimer?.cancel();
    super.dispose();
  }

  // NEW: The entire call initiation logic, copied from your test page.
  Future<void> _initiateCall() async {
    // Note: It's good practice to stop the AI session to free up camera/mic
    // before starting a video call.
    context.read<SessionCubit>().stopSession();

    setState(() {
      _isCalling = true;
    });

    try {
      final meetingId = await createMeeting();
      final videoSdkToken = dotenv.env['AUTH_TOKEN'];
      if (videoSdkToken == null) {
        throw Exception("VideoSDK Token not found in .env file.");
      }

      final callId = await _firebaseService.addCallRequest(meetingId);

      _callSubscription = _firebaseService.listenForCallAcceptance(callId).listen((
        event,
      ) {
        if (!event.snapshot.exists) {
          _callSubscription?.cancel();
          if (!mounted) return;

          // Using pushReplacement ensures the user can't go "back" to the calling screen.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MeetingScreen(
                meetingId: meetingId,
                token: videoSdkToken,
                displayName: "User in Need",
              ),
            ),
          );
        }
      });

      // Timeout after 60 seconds
      Future.delayed(const Duration(seconds: 60), () {
        if (mounted && _isCalling) {
          _callSubscription?.cancel();
          _firebaseService.answerCall(callId);
          setState(() {
            _isCalling = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "No volunteer was available. Please try again later.",
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
        );
        setState(() {
          _isCalling = false;
        });
      }
    }
  }

  // NEW: Logic to handle tap events and detect a triple tap.
  void _handleTripleTap() {
    // A screen reader might intercept gestures. We want to ensure we're not already in a call.
    if (_isCalling) return;

    _tapCount++;
    // We restart the timer on each tap.
    _tapTimer?.cancel();

    if (_tapCount == 3) {
      // Triple tap detected!
      print("Triple tap detected! Initiating call..."); // For debugging
      _initiateCall();
      _tapCount = 0; // Reset for next time
    } else {
      // If 3 taps don't happen within 500ms, reset the counter.
      _tapTimer = Timer(const Duration(milliseconds: 500), () {
        _tapCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _showDebug ? Colors.redAccent : Colors.blueGrey,
        onPressed: () => setState(() => _showDebug = !_showDebug),
        child: Icon(_showDebug ? Icons.close : Icons.bug_report),
        tooltip: 'Debug',
      ),
      // NEW: Wrap the body in a GestureDetector to capture taps anywhere on the screen.
      body: GestureDetector(
        onTap: _handleTripleTap, // The magic happens here!
        // Use a transparent behavior to ensure the detector covers the whole area,
        // even empty spaces.
        behavior: HitTestBehavior.translucent,
        child: BlocConsumer<SessionCubit, SessionState>(
          listenWhen: (previous, current) =>
              previous.error != current.error && current.error != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
          builder: (context, state) {
            final cubit = context.read<SessionCubit>();
            final cameraController = cubit.cameraController;

            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'See for Me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Listening & Watching...\n(Triple tap to call a volunteer)', // NEW: User instruction
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (_showDebug)
                  _buildDebugOverlay(state, cameraController, cubit),
                // NEW: Show a calling overlay when a call is being initiated.
                if (_isCalling) _buildCallingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  // NEW: A helper widget to show feedback while the call is connecting.
  Widget _buildCallingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Calling a Volunteer...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // The rest of your debug widgets remain unchanged.
  // ... _buildDebugOverlay, _cameraPreviewBox, _statusLine, _debugButton ...
  Widget _buildDebugOverlay(
    SessionState state,
    CameraController? controller,
    SessionCubit cubit,
  ) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.92),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Debug Panel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      tooltip: 'Restart Session',
                      // startSession handles both initial connections and reconnections cleanly.
                      onPressed: () => cubit.startSession(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _wsController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'WebSocket URL:port',
                    labelStyle: const TextStyle(color: Colors.white54),
                    hintText: 'ws://host:port/ws/live',
                    hintStyle: const TextStyle(color: Colors.white24),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.lightGreenAccent,
                      ),
                      onPressed: () {
                        cubit.updateWebSocketUrl(_wsController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('WebSocket URL updated'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _debugButton(
                      icon: Icons.cameraswitch,
                      label: 'Switch Cam',
                      onTap: () => cubit.switchCamera(),
                    ),
                    _debugButton(
                      icon: state.isRecording ? Icons.mic : Icons.mic_none,
                      label: state.isRecording ? 'Stop Mic' : 'Start Mic',
                      onTap: () => state.isRecording
                          ? cubit.stopRecording()
                          : cubit.startRecording(),
                    ),
                    _debugButton(
                      icon: Icons.stop_circle,
                      label: 'End Session',
                      onTap: () => cubit.stopSession(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.isInitializingCamera)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ),
                    ),
                  )
                else if (state.showCameraPreview &&
                    controller != null &&
                    controller.value.isInitialized)
                  _cameraPreviewBox(controller)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'Camera Inactive',
                        style: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _statusLine('Session', state.isSessionStarted),
                _statusLine(
                  'WebSocket',
                  state.connecting
                      ? null
                      : (state.isSessionStarted && !state.isError),
                ),
                _statusLine('Recording', state.isRecording),
                _statusLine('Bot Speaking', state.isBotSpeaking),
                _statusLine('Streaming Images', state.isStreamingImages),
                if (state.isError && state.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cameraPreviewBox(CameraController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        // Add a unique key. This forces Flutter to rebuild the widget from scratch
        // when the controller instance changes, fixing the refresh/reconnect bug.
        child: CameraPreview(controller, key: ValueKey(controller.hashCode)),
      ),
    );
  }

  Widget _statusLine(String label, bool? active) {
    Color color;
    String text;
    if (active == null) {
      text = 'Connecting...';
      color = Colors.amberAccent;
    } else if (active) {
      text = 'Active';
      color = Colors.lightGreenAccent;
    } else {
      text = 'Idle';
      color = Colors.white30;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.white60)),
          ),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _debugButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
