import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_voice_engine/flutter_voice_engine.dart';
import 'package:web_socket_channel/io.dart';
import 'package:image/image.dart' as imglib;
import 'package:permission_handler/permission_handler.dart';

// Enum for different interaction modes
enum SessionMode {
  idle, // Waiting for gestures, camera preview active
  offline, // MLKit analysis in progress
  online, // WebSocket connection active
}

// SessionState
class SessionState {
  final SessionMode mode;
  final bool isSessionStarted;
  final bool isRecording;

  final bool isError;
  final String? error;

  final bool isInitializingCamera;
  final bool isCameraActive;
  final bool showCameraPreview;
  final bool isStreamingImages;

  final bool connecting;
  final bool isBotSpeaking;

  final double visualizerAmplitude;

  SessionState({
    this.mode = SessionMode.idle,
    this.isSessionStarted = false,
    this.isRecording = false,
    this.isError = false,
    this.error,
    this.isInitializingCamera = false,
    this.isCameraActive = false,
    this.showCameraPreview = false,
    this.isStreamingImages = false,
    this.connecting = false,
    this.isBotSpeaking = false,
    this.visualizerAmplitude = 0.0,
  });

  SessionState copyWith({
    SessionMode? mode,
    bool? isSessionStarted,
    bool? isRecording,
    bool? isError,
    String? error,
    bool? isInitializingCamera,
    bool? isCameraActive,
    bool? showCameraPreview,
    bool? isStreamingImages,
    bool? isBotSpeaking,
    bool? connecting,
    double? visualizerAmplitude,
  }) {
    return SessionState(
      mode: mode ?? this.mode,
      isSessionStarted: isSessionStarted ?? this.isSessionStarted,
      isRecording: isRecording ?? this.isRecording,
      isError: isError ?? this.isError,
      error: error, // Allow setting error to null
      isInitializingCamera: isInitializingCamera ?? this.isInitializingCamera,
      isCameraActive: isCameraActive ?? this.isCameraActive,
      showCameraPreview: showCameraPreview ?? this.showCameraPreview,
      isStreamingImages: isStreamingImages ?? this.isStreamingImages,
      connecting: connecting ?? this.connecting,
      isBotSpeaking: isBotSpeaking ?? this.isBotSpeaking,
      visualizerAmplitude: visualizerAmplitude ?? this.visualizerAmplitude,
    );
  }
}

String WEBSOCKET_URL = "ws://10.105.65.63:8000/ws/live";

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(SessionState());

  FlutterVoiceEngine? _voiceEngine;
  IOWebSocketChannel? _webSocket;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  CameraImage? _latestCameraImage;
  StreamSubscription<dynamic>? _voiceEngineSubscription;
  Timer? _imageSendTimer;

  bool _isInitialized = false;
  bool _isWebSocketOpen = false;
  bool _isConnecting = false; // Flag to prevent connection spam

  CameraController? get cameraController => _cameraController;

  @override
  Future<void> close() async {
    print('Closing Session Cubit');
    await stopSession(); // Use stopSession for a clean shutdown
    super.close();
  }

  Future<void> startSession() async {
    print('Starting session in idle mode');

    await requestMicrophonePermission();
    await requestCameraPermission();

    try {
      // Only initialize camera for idle mode, not voice engine or websocket
      await _initCamera();
      emit(
        state.copyWith(
          mode: SessionMode.idle,
          isSessionStarted: true,
          isError: false,
          error: null,
        ),
      );
    } catch (e, stackTrace) {
      print('Initialization failed: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Initialization failed: $e',
          isError: true,
          isSessionStarted: false,
        ),
      );
    }
  }

  // New method for starting online mode
  Future<void> startOnlineMode() async {
    if (state.mode != SessionMode.idle) return;

    print('Starting online mode');
    emit(state.copyWith(mode: SessionMode.online, connecting: true));

    try {
      // Reinitialize camera with yuv420 format for WebSocket compatibility
      await _initCameraForOnlineMode();
      await _initVoiceEngine();
      connectWebSocket();
    } catch (e, stackTrace) {
      print('Online mode initialization failed: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Failed to start online mode: $e',
          isError: true,
          mode: SessionMode.idle,
          connecting: false,
        ),
      );
    }
  }

  // New method for starting offline mode
  Future<void> startOfflineMode() async {
    if (state.mode != SessionMode.idle) return;

    print('Starting offline mode');
    emit(state.copyWith(mode: SessionMode.offline));

    // Ensure camera is using nv21 format for MLKit compatibility
    await _initCameraForOfflineMode();
  }

  // New method for canceling current mode and returning to idle
  Future<void> cancelCurrentMode() async {
    print('Canceling current mode: ${state.mode}');

    switch (state.mode) {
      case SessionMode.online:
        await _stopOnlineMode();
        break;
      case SessionMode.offline:
        await _stopOfflineMode();
        break;
      case SessionMode.idle:
        // Already idle, nothing to do
        break;
    }

    emit(
      state.copyWith(
        mode: SessionMode.idle,
        isRecording: false,
        connecting: false,
        isBotSpeaking: false,
        isError: false,
        error: null,
      ),
    );

    // Reinitialize camera to nv21 format for idle/offline compatibility
    if (state.isCameraActive) {
      await _initCamera();
    }
  }

  Future<void> _stopOnlineMode() async {
    print('Stopping online mode');
    _imageSendTimer?.cancel();
    _imageSendTimer = null;

    // --- START: MODIFIED BLOCK ---
    // 1. Stop recording and playback FIRST, while the engine object still exists.
    await stopRecording();
    await _voiceEngine?.stopPlayback();

    // 2. NOW, it is safe to shut down and nullify the engine.
    if (_voiceEngine?.isInitialized ?? false) {
      if (Platform.isAndroid) {
        await _voiceEngine?.shutdownAll();
      } else {
        await _voiceEngine?.shutdownBot();
      }
      _voiceEngine = null; // Nullify the instance to force re-initialization
    }

    // 3. Finally, close the WebSocket connection.
    _webSocket?.sink.close();
    _isWebSocketOpen = false;
    _isConnecting = false;
    // --- END: MODIFIED BLOCK ---
  }

  Future<void> _stopOfflineMode() async {
    print('Stopping offline mode');
    // Any cleanup needed for offline mode
  }

  Future<void> stopSession() async {
    print('Stopping session');
    _imageSendTimer?.cancel();
    _imageSendTimer = null;
    _latestCameraImage = null;

    // --- START: MODIFIED BLOCK (Applying the same logic here for consistency) ---
    // 1. Stop recording and playback first.
    await stopRecording();
    await _voiceEngine?.stopPlayback();

    // 2. Shut down and nullify the engine.
    if (_voiceEngine?.isInitialized ?? false) {
      if (Platform.isAndroid) {
        await _voiceEngine?.shutdownAll();
      } else {
        await _voiceEngine?.shutdownBot();
      }
      _voiceEngine = null;
    }
    // --- END: MODIFIED BLOCK ---

    if (_cameraController != null) {
      await _cameraController?.stopImageStream();
      await _cameraController?.dispose();
      _cameraController = null;
    }

    _webSocket?.sink.close();
    _isWebSocketOpen = false;
    _isConnecting = false;
    _isInitialized = false;

    emit(SessionState()); // Reset to the initial state
  }

  Future<void> _initVoiceEngine() async {
    print('Initializing VoiceEngine');
    try {
      if (_voiceEngine != null && _voiceEngine!.isInitialized) {
        print('VoiceEngine already initialized, reusing.');
        return;
      }

      _voiceEngine = FlutterVoiceEngine();
      _voiceEngine!.audioConfig = AudioConfig(
        sampleRate: 16000,
        channels: 1,
        bitDepth: 16,
        bufferSize: 4096,
        enableAEC: true,
      );
      _voiceEngine!.sessionConfig = AudioSessionConfig(
        category: AudioCategory.playAndRecord,
        mode: AudioMode.spokenAudio,
        options: {
          AudioOption.defaultToSpeaker,
          AudioOption.allowBluetoothA2DP,
          AudioOption.mixWithOthers,
        },
      );
      await _voiceEngine!.initialize();
      print('VoiceEngine initialized');
    } catch (e, stackTrace) {
      print('VoiceEngine initialization failed: $e\n$stackTrace');
      rethrow;
    }
  }

  void connectWebSocket() {
    if (_isConnecting || _isWebSocketOpen) {
      print(
        'WebSocket connection attempt ignored: already connecting or connected.',
      );
      return;
    }

    if (state.mode != SessionMode.online) {
      print('WebSocket connection ignored: not in online mode.');
      return;
    }

    print('Connecting to WebSocket...');
    _isConnecting = true;
    emit(state.copyWith(connecting: true, isError: false, error: null));

    try {
      _webSocket = IOWebSocketChannel.connect(Uri.parse(WEBSOCKET_URL));
      _isWebSocketOpen = true;

      _webSocket!.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onDone: () {
          print('WebSocket disconnected.');
          _isWebSocketOpen = false;
          _isConnecting = false;
          _imageSendTimer?.cancel();
          _imageSendTimer = null;
          if (state.mode == SessionMode.online) {
            emit(
              state.copyWith(
                mode: SessionMode.idle,
                isRecording: false,
                isError: true,
                error: 'WebSocket disconnected. Returning to idle mode.',
                connecting: false,
                isStreamingImages: false,
              ),
            );
          }
          _stopAllStreams();
        },
        onError: (error, stackTrace) {
          print('WebSocket error: $error\n$stackTrace');
          _isWebSocketOpen = false;
          _isConnecting = false;
          _imageSendTimer?.cancel();
          _imageSendTimer = null;
          emit(
            state.copyWith(
              isError: true,
              error: 'WebSocket error: $error',
              mode: SessionMode.idle,
              connecting: false,
              isStreamingImages: false,
            ),
          );
          _stopAllStreams();
        },
      );
      print('WebSocket connection attempt successful.');
    } catch (e, stackTrace) {
      print('WebSocket connection failed: $e\n$stackTrace');
      _isConnecting = false;
      emit(
        state.copyWith(
          error: 'WebSocket connection failed: $e',
          isError: true,
          mode: SessionMode.idle,
          connecting: false,
        ),
      );
    }
  }

  Future<void> _handleWebSocketMessage(dynamic message) async {
    try {
      if (message is String) {
        final data = jsonDecode(message);
        final type = data['type'] as String;
        switch (type) {
          case 'instantiating_connection':
            print('Gemini session is being set up...');
            emit(state.copyWith(connecting: true));
            break;
          case 'successfully_connected':
            print('Gemini session established! Starting audio...');
            _isConnecting = false;
            await startRecording();
            print('Audio ready, initializing image streaming...');

            // Ensure camera is streaming before starting image timer
            await _ensureCameraStreamingForOnlineMode();
            _startImageSendTimer(); // Start sending images from existing camera

            emit(
              state.copyWith(
                mode: SessionMode.online,
                isSessionStarted: true,
                connecting: false,
                isStreamingImages: true,
              ),
            );
            break;
          case 'error':
            final errorMsg = data['message'] as String? ?? 'Unknown error';
            print('Backend error: $errorMsg');
            _isConnecting = false;
            emit(
              state.copyWith(error: errorMsg, isError: true, connecting: false),
            );
            _stopAllStreams();
            break;
          case 'turn_complete':
            print('TURN COMPLETE received');
            await _voiceEngine!.stopPlayback();
            emit(state.copyWith(isBotSpeaking: false));
            break;
          case 'interrupted':
            print('INTERRUPTED received');
            await _voiceEngine!.stopPlayback();
            emit(state.copyWith(isBotSpeaking: false));
            break;
          default:
            print('Unhandled message type: $type');
        }
      } else {
        final Uint8List audioData = message as Uint8List;
        final amplitude = computeRMSAmplitude(audioData);
        emit(
          state.copyWith(isBotSpeaking: true, visualizerAmplitude: amplitude),
        );
        try {
          // Amplify audio data by a factor (e.g., 2x) //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          final Uint8List amplifiedAudio = _amplifyAudio(
            audioData,
            amplificationFactor: 12.0,
          );
          await _voiceEngine!.playAudioChunk(amplifiedAudio);
          // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

          // await _voiceEngine!.playAudioChunk(audioData);
        } catch (e, stackTrace) {
          print('Playback error: $e\n$stackTrace');
          emit(state.copyWith(error: 'Playback error: $e', isError: true));
        }
      }
    } catch (e, stackTrace) {
      print('WebSocket message error: $e\n$stackTrace');
      emit(state.copyWith(error: 'WebSocket message error: $e', isError: true));
    }
  }

  Future<void> _stopAllStreams() async {
    _imageSendTimer?.cancel();
    _imageSendTimer = null;
    _latestCameraImage = null;
    await stopRecording();
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController?.stopImageStream();
    }
    emit(
      state.copyWith(
        isRecording: false,
        isCameraActive: state.isCameraActive,
        showCameraPreview: state.showCameraPreview,
        isStreamingImages: false,
        connecting: false,
        isBotSpeaking: false,
      ),
    );
  }

  Future<void> _initCamera() async {
    print('Initializing Camera for idle mode (nv21 format)');
    await _initCameraWithFormat(ImageFormatGroup.nv21);
  }

  Future<void> _initCameraForOnlineMode() async {
    print('Initializing Camera for online mode (yuv420 format for WebSocket)');
    await _initCameraWithFormat(
      Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );
  }

  Future<void> _initCameraForOfflineMode() async {
    print('Initializing Camera for offline mode (nv21 format for MLKit)');
    await _initCameraWithFormat(
      Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
  }

  Future<void> _initCameraWithFormat(ImageFormatGroup format) async {
    print('Initializing Camera with format: $format');
    emit(
      state.copyWith(isInitializingCamera: true, error: null, isError: false),
    );
    try {
      // Always dispose and reinitialize to ensure correct format
      if (_cameraController != null) {
        if (_cameraController!.value.isStreamingImages) {
          await _cameraController!.stopImageStream();
        }
        await _cameraController?.dispose();
        _cameraController = null;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception("No cameras available on this device.");
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: format,
      );

      await _cameraController!.initialize();
      print('Camera initialized with format $format. Starting image stream...');

      await _cameraController!.startImageStream((CameraImage image) {
        _latestCameraImage = image;
      });

      emit(
        state.copyWith(
          isInitializingCamera: false,
          isCameraActive: true,
          showCameraPreview: true,
        ),
      );
    } catch (e, stackTrace) {
      print('Camera initialization failed: $e\n$stackTrace');
      emit(
        state.copyWith(
          isInitializingCamera: false,
          isCameraActive: false,
          showCameraPreview: false,
          isStreamingImages: false,
          error: 'Camera initialization failed: $e',
          isError: true,
        ),
      );
      await _cameraController?.dispose();
      _cameraController = null;
    }
  }

  Future<void> _ensureCameraStreamingForOnlineMode() async {
    print('Ensuring camera is streaming for online mode...');

    // Always reinitialize camera for online mode to ensure yuv420 format
    print('Reinitializing camera with yuv420 format for online mode...');
    await _initCameraForOnlineMode();
  }

  void _startImageSendTimer() {
    _imageSendTimer?.cancel();
    print('Starting image send timer...');
    _imageSendTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) async {
      if (_latestCameraImage != null &&
          _webSocket != null &&
          _isWebSocketOpen) {
        try {
          print('Sending image to WebSocket...');
          final Uint8List? jpegBytes = await compute(
            convertCameraImageToJpeg,
            _latestCameraImage!,
          );

          if (jpegBytes != null) {
            final String base64Image = base64Encode(jpegBytes);
            final Map<String, dynamic> imageMessage = {
              "type": "image_input",
              "image_data": base64Image,
              "mime_type": "image/jpeg",
            };
            _webSocket!.sink.add(jsonEncode(imageMessage));
            print('Image sent successfully (${jpegBytes.length} bytes)');
          } else {
            print('Failed to convert camera image to JPEG');
          }
        } catch (e, stackTrace) {
          print("Error processing/sending timed picture: $e\n$stackTrace");
        }
      } else {
        print(
          'Cannot send image: latestCameraImage=${_latestCameraImage != null}, webSocket=${_webSocket != null}, webSocketOpen=$_isWebSocketOpen',
        );
        if (_cameraController == null ||
            !_cameraController!.value.isInitialized) {
          print("Camera not active for timed image send. Stopping timer.");
          timer.cancel();
          _imageSendTimer = null;
          emit(state.copyWith(isStreamingImages: false));
        }
      }
    });
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) {
      print("Switch camera failed: Less than 2 cameras available.");
      emit(state.copyWith(error: 'Only one camera found.', isError: true));
      Future.delayed(
        const Duration(seconds: 2),
        () => emit(state.copyWith(isError: false, error: null)),
      );
      return;
    }
    if (state.isInitializingCamera) {
      print("Already switching camera.");
      return;
    }

    emit(state.copyWith(isInitializingCamera: true, showCameraPreview: false));

    try {
      final CameraDescription currentCamera = _cameraController!.description;
      final CameraDescription newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentCamera.lensDirection,
      );

      await _cameraController?.stopImageStream();
      await _cameraController?.dispose();
      _cameraController = null;
      _latestCameraImage = null;

      // Choose format based on current mode
      ImageFormatGroup desiredFormat;
      if (state.mode == SessionMode.online) {
        // Online mode uses yuv420 for WebSocket compatibility
        desiredFormat = Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888;
      } else {
        // Idle and offline modes use nv21 for MLKit compatibility
        desiredFormat = Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888;
      }

      _cameraController = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: desiredFormat,
      );

      await _cameraController!.initialize();
      print('Camera switched and initialized. Starting image stream...');

      await _cameraController!.startImageStream((CameraImage image) {
        _latestCameraImage = image;
      });

      emit(
        state.copyWith(
          isInitializingCamera: false,
          isCameraActive: true,
          showCameraPreview: true,
          isStreamingImages: true,
        ),
      );
    } catch (e, stackTrace) {
      print('Error switching camera: $e\n$stackTrace');
      emit(
        state.copyWith(
          error: 'Error switching camera: $e',
          isError: true,
          isInitializingCamera: false,
        ),
      );
    }
  }

  // The corrected startRecording() function

  // Add these print statements to your startRecording() function

  Future<void> startRecording() async {
    print("--- START RECORDING CALLED ---"); // <-- ADD THIS
    try {
      if (!(_voiceEngine?.isInitialized ?? false)) {
        print("Voice engine not ready, initializing..."); // <-- ADD THIS
        await _initVoiceEngine();
      }

      emit(state.copyWith(isRecording: true));
      print("--- STATE EMITTED: isRecording is now true ---"); // <-- ADD THIS

      _voiceEngineSubscription?.cancel();
      _voiceEngineSubscription = _voiceEngine!.audioChunkStream.listen(
        (audioData) {
          // This is the most important print statement
          print(
            "--- AUDIO CHUNK RECEIVED! Length: ${audioData.length}, isRecording state: ${state.isRecording} ---",
          ); // <-- ADD THIS

          if (_webSocket != null && _isWebSocketOpen && state.isRecording) {
            _webSocket!.sink.add(audioData);
          }
          final amplitude = computeRMSAmplitude(audioData);
          emit(state.copyWith(visualizerAmplitude: amplitude));
        },
        onError: (error, stackTrace) {
          print(
            '!!! Recording stream ERROR: $error\n$stackTrace',
          ); // <-- ADD THIS
          emit(state.copyWith(error: 'Recording error: $error', isError: true));
        },
        onDone: () {
          print("--- Recording stream is DONE. ---"); // <-- ADD THIS
        },
      );

      print("Now calling _voiceEngine.startRecording()..."); // <-- ADD THIS
      await _voiceEngine!.startRecording();
      print(
        "--- Call to _voiceEngine.startRecording() is COMPLETE. ---",
      ); // <-- ADD THIS
    } catch (e, stackTrace) {
      print('!!! FAILED to start recording: $e\n$stackTrace'); // <-- ADD THIS
      emit(
        state.copyWith(error: 'Failed to start recording: $e', isError: true),
      );
    }
  }

  Future<void> stopRecording() async {
    print('Stopping recording');
    try {
      _voiceEngineSubscription?.cancel();
      _voiceEngineSubscription = null;
      if (_voiceEngine?.isRecording ?? false) {
        await _voiceEngine!.stopRecording();
      }
      if (_webSocket != null && _isWebSocketOpen) {
        _webSocket!.sink.add(jsonEncode({"type": "audio_stream_end"}));
      }
      emit(state.copyWith(isRecording: false));
    } catch (e, stackTrace) {
      print('Error stopping recording: $e\n$stackTrace');
      emit(
        state.copyWith(error: 'Error stopping recording: $e', isError: true),
      );
    }
  }

  double computeRMSAmplitude(Uint8List pcm, {int bytesPerSample = 2}) {
    if (pcm.isEmpty) return 0.0;
    int sampleCount = pcm.length ~/ bytesPerSample;
    if (sampleCount == 0) return 0.0;
    double sumSquares = 0;
    for (int i = 0; i < pcm.length; i += bytesPerSample) {
      int sample = pcm.buffer.asByteData().getInt16(i, Endian.little);
      sumSquares += sample * sample;
    }
    double rms = sqrt(sumSquares / sampleCount) / 32768.0;
    return rms.clamp(0.0, 1.0);
  }

  static Future<Uint8List?> convertCameraImageToJpeg(
    CameraImage cameraImage,
  ) async {
    try {
      imglib.Image? img;
      if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        img = imglib.Image.fromBytes(
          width: cameraImage.width,
          height: cameraImage.height,
          bytes: cameraImage.planes[0].bytes.buffer,
          order: imglib.ChannelOrder.bgra,
        );
      } else if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        final int width = cameraImage.width;
        final int height = cameraImage.height;
        final Uint8List yPlane = cameraImage.planes[0].bytes;
        final Uint8List uPlane = cameraImage.planes[1].bytes;
        final Uint8List vPlane = cameraImage.planes[2].bytes;
        final int yRowStride = cameraImage.planes[0].bytesPerRow;
        final int uvRowStride = cameraImage.planes[1].bytesPerRow;
        final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

        img = imglib.Image(width: width, height: height);

        for (int h = 0; h < height; h++) {
          for (int w = 0; w < width; w++) {
            final int yIndex = h * yRowStride + w;
            final int uvIndex =
                (h ~/ 2) * uvRowStride + (w ~/ 2) * uvPixelStride;

            if (yIndex >= yPlane.length ||
                uvIndex >= uPlane.length ||
                uvIndex >= vPlane.length) {
              continue;
            }
            final int Y = yPlane[yIndex];
            final int U = uPlane[uvIndex];
            final int V = vPlane[uvIndex];
            int r = (Y + (V - 128) * 1.402).round().clamp(0, 255);
            int g = (Y - (U - 128) * 0.344136 - (V - 128) * 0.714136)
                .round()
                .clamp(0, 255);
            int b = (Y + (U - 128) * 1.772).round().clamp(0, 255);
            img.setPixelRgba(w, h, r, g, b, 255);
          }
        }
      } else {
        return null;
      }
      return Uint8List.fromList(imglib.encodeJpg(img, quality: 80));
    } catch (e, stackTrace) {
      print('Error converting CameraImage to JPEG: $e\n$stackTrace');
      return null;
    }
  }

  static Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        throw Exception('Camera permission denied');
      }
    }
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    final requestStatus = await Permission.microphone.request();
    return requestStatus.isGranted;
  }

  // New method to get current camera image for offline analysis
  CameraImage? getCurrentCameraImage() {
    return _latestCameraImage;
  }

  void updateWebSocketUrl(String url) {
    if (url.isEmpty || url == WEBSOCKET_URL) return;
    WEBSOCKET_URL = url;
    print('WebSocket URL updated to: $WEBSOCKET_URL');
    try {
      _webSocket?.sink.close();
    } catch (_) {}
    _isWebSocketOpen = false;
    _isConnecting = false;
    if (state.isSessionStarted || _isInitialized) {
      connectWebSocket();
    }
  }
}

//
//
//
//
//
//
//
//
//
//
//

Uint8List _amplifyAudio(
  Uint8List audioData, {
  double amplificationFactor = 2.0,
}) {
  final ByteData byteData = audioData.buffer.asByteData();
  final Uint8List amplifiedData = Uint8List(audioData.length);
  final ByteData amplifiedByteData = amplifiedData.buffer.asByteData();

  for (int i = 0; i < audioData.length; i += 2) {
    int sample = byteData.getInt16(i, Endian.little);
    int amplifiedSample = (sample * amplificationFactor).round();
    // Clamp to prevent distortion
    amplifiedSample = amplifiedSample.clamp(-32768, 32767);
    amplifiedByteData.setInt16(i, amplifiedSample, Endian.little);
  }

  return amplifiedData;
}
