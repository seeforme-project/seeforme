import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seeforme/api_call.dart';
import 'package:seeforme/liveai/session_cubit.dart';
import 'package:seeforme/meeting_screen.dart';
import 'package:seeforme/services/firebase_service.dart';
import 'package:seeforme/services/mlkit_service.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with WidgetsBindingObserver {
  bool _showDebug = false;

  // Services
  final _firebaseService = FirebaseService();
  final _mlkitService = MLKitService();
  StreamSubscription? _callSubscription;

  // Gesture detection variables
  int _tapCount = 0;
  Timer? _tapTimer;

  @override
  void initState() {
    super.initState();

    // Initialize MLKit service
    _mlkitService.initialize();

    // Start session in idle mode (camera preview only, no API connection)
    context.read<SessionCubit>().startSession();
  }

  Widget _debugButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraPreviewBox(CameraController controller) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    context.read<SessionCubit>().stopSession();
    _callSubscription?.cancel();
    _tapTimer?.cancel();
    _mlkitService.dispose();
    super.dispose();
  }

  // Handle swipe up gesture - Start online mode
  Future<void> _handleSwipeUp() async {
    final cubit = context.read<SessionCubit>();
    if (cubit.state.mode != SessionMode.idle) return;

    await _mlkitService.speak("Connecting to online assistant...");
    await cubit.startOnlineMode();
  }

  // UPDATED: Handle swipe down gesture - Start offline mode
  Future<void> _handleSwipeDown() async {
    final cubit = context.read<SessionCubit>();
    if (cubit.state.mode != SessionMode.idle) return;

    await cubit.startOfflineMode();

    final cameraImage = cubit.getCurrentCameraImage();
    // Get the description of the camera to determine sensor orientation
    final cameraDescription = cubit.cameraController?.description;

    if (cameraImage != null && cameraDescription != null) {
      // Pass both the image AND the camera description to the service
      await _mlkitService.performOfflineAnalysis(
        cameraImage,
        cameraDescription,
      );
    } else {
      await _mlkitService.speak("Camera image not available for analysis.");
    }

    // Return to idle mode after analysis
    await cubit.cancelCurrentMode();
  }

  // Handle double tap gesture - Cancel current mode
  Future<void> _handleDoubleTap() async {
    final cubit = context.read<SessionCubit>();
    if (cubit.state.mode == SessionMode.idle) return;

    // Stop any ongoing TTS from MLKit before announcing cancellation
    await _mlkitService.stopSpeaking();

    switch (cubit.state.mode) {
      case SessionMode.online:
        await _mlkitService.speak("Disconnected from online assistant.");
        break;
      case SessionMode.offline:
        await _mlkitService.speak("Offline assist stopped.");
        break;
      case SessionMode.idle:
        return;
    }

    await cubit.cancelCurrentMode();
  }

  // Combined tap handler for both double and triple taps
  void _handleTap() {
    _tapCount++;
    _tapTimer?.cancel(); // Cancel any previous timer

    if (_tapCount == 3) {
      // Triple tap detected
      _handleTripleTap();
      _tapCount = 0;
    } else {
      // On the first or second tap, start a timer.
      // If another tap comes, it will cancel this and check again.
      // If it expires, it will execute the appropriate action.
      _tapTimer = Timer(const Duration(milliseconds: 300), () {
        if (_tapCount == 1) {
          // Single tap - you can add an action here if you want
        } else if (_tapCount == 2) {
          // Double tap action
          _handleDoubleTap();
        }
        _tapCount = 0; // Reset after the timer fires
      });
    }
  }

  // Handle triple tap gesture for calling volunteers
  void _handleTripleTap() {
    final cubit = context.read<SessionCubit>();
    if (cubit.state.mode != SessionMode.idle) return;

    print("Triple tap detected! Initiating call...");
    _initiateCall();
  }

  // Legacy call functionality (unchanged)
  Future<void> _initiateCall() async {
    context.read<SessionCubit>().stopSession();
    try {
      final meetingId = await createMeeting();
      final videoSdkToken = dotenv.env['AUTH_TOKEN'];
      if (videoSdkToken == null) {
        throw Exception("VideoSDK Token not found in .env file.");
      }

      final callId = await _firebaseService.addCallRequest(meetingId);
      _callSubscription = _firebaseService
          .listenForCallAcceptance(callId)
          .listen((event) {
            if (!event.snapshot.exists) {
              _callSubscription?.cancel();
              if (!mounted) return;

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

      Future.delayed(const Duration(seconds: 60), () {
        if (mounted) {
          _callSubscription?.cancel();
          _firebaseService.answerCall(callId);
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
      }
    }
  }

  // -- BUILD METHOD AND UI WIDGETS BELOW (UNCHANGED) --

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
      body: GestureDetector(
        onTap: _handleTap, // Use the unified tap handler
        onPanEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond;
          final dy = velocity.dy;

          if (dy.abs() > 300) {
            // Adjusted sensitivity
            if (dy < -300) {
              // Swipe up
              _handleSwipeUp();
            } else if (dy > 300) {
              // Swipe down
              _handleSwipeDown();
            }
          }
        },
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
                // Main content overlay (black screen with title)
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
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildModeInstructions(state.mode),
                    ],
                  ),
                ),

                // Debug overlay
                if (_showDebug)
                  _buildDebugOverlay(state, cameraController, cubit),

                // Mode-specific overlays
                if (state.mode == SessionMode.offline) _buildOfflineOverlay(),
                if (state.mode == SessionMode.online && state.connecting)
                  _buildConnectingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeInstructions(SessionMode mode) {
    String instructions;
    Color color;

    switch (mode) {
      case SessionMode.idle:
        instructions =
            'Swipe up for online assistant\nSwipe down for offline analysis\nTriple tap to call volunteer\nDouble tap to cancel';
        color = Colors.white70;
        break;
      case SessionMode.offline:
        instructions = 'Analyzing with offline AI...\nDouble tap to cancel';
        color = Colors.greenAccent;
        break;
      case SessionMode.online:
        instructions =
            'Connected to online assistant\nDouble tap to disconnect';
        color = Colors.blueAccent;
        break;
    }

    return Text(
      instructions,
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        shadows: [
          Shadow(
            offset: Offset(1, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.8),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOfflineOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.greenAccent),
            SizedBox(height: 24),
            Text(
              'Offline AI Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Analyzing image with MLKit...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 24),
            Text(
              'Connecting to Online Assistant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

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
                      onPressed: () => cubit.startSession(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'API Connection: Direct Gemini Live',
                  style: TextStyle(
                    color: Colors.lightGreenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                      icon: Icons.cloud,
                      label: 'Online Mode',
                      onTap: () => _handleSwipeUp(),
                    ),
                    _debugButton(
                      icon: Icons.offline_bolt,
                      label: 'Offline Mode',
                      onTap: () => _handleSwipeDown(),
                    ),
                    _debugButton(
                      icon: Icons.stop_circle,
                      label: 'Cancel Mode',
                      onTap: () => _handleDoubleTap(),
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
                _statusLineString('Mode', state.mode.name),
                _statusLine('Session', state.isSessionStarted),
                _statusLine(
                  'Gemini Live API',
                  state.connecting
                      ? null
                      : (state.mode == SessionMode.online && !state.isError),
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

  Widget _statusLine(String label, bool? active) {
    final color = active == true ? Colors.lightGreenAccent : Colors.white30;
    final text = active == true ? 'Active' : 'Idle';
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

  Widget _statusLineString(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.white60)),
          ),
          Text(value, style: const TextStyle(color: Colors.lightGreenAccent)),
        ],
      ),
    );
  }
}
