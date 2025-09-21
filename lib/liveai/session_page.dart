import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeforme/liveai/session_cubit.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with WidgetsBindingObserver {
  bool _showDebug = false;
  late TextEditingController _wsController;

  @override
  void initState() {
    super.initState();
    _wsController = TextEditingController(text: WEBSOCKET_URL);
    context.read<SessionCubit>().startSession();
  }

  @override
  void dispose() {
    _wsController.dispose();
    // Stop the session properly when the page is removed to avoid resource leaks.
    context.read<SessionCubit>().stopSession();
    super.dispose();
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
      body: BlocConsumer<SessionCubit, SessionState>(
        // Only show SnackBar when the error message is new.
        // This prevents the same error from showing repeatedly.
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
                      'Listening & Watching...',
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
            ],
          );
        },
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
