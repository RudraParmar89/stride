import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

// Import our helper files
import 'logic/camera_utils.dart';
import 'logic/pose_calculator.dart';

class MLExercisePage extends StatefulWidget {
  final String taskName;
  const MLExercisePage({super.key, required this.taskName});

  @override
  State<MLExercisePage> createState() => _MLExercisePageState();
}

class _MLExercisePageState extends State<MLExercisePage> with WidgetsBindingObserver {
  // Camera & AI
  CameraController? _controller;
  CameraDescription? _frontCamera;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  bool _isProcessing = false;

  // Logic Engine
  final PoseCalculator _calculator = PoseCalculator();

  // Anti-Cheat State
  int _shields = 3; // 3 Strikes
  bool _failed = false;
  String _failReason = "";
  String _statusMessage = "ALIGN BODY";
  DateTime? _appPausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  // =================================================
  // 🛡️ ANTI-CHEAT: VOID PENALTY (Backgrounding)
  // =================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_failed) return;

    if (state == AppLifecycleState.paused) {
      _appPausedAt = DateTime.now();
      // Stop stream to save battery/prevent crash
      _controller?.stopImageStream();
    }
    else if (state == AppLifecycleState.resumed) {
      if (_appPausedAt != null) {
        final timeGone = DateTime.now().difference(_appPausedAt!);
        _appPausedAt = null;

        // Restart stream
        _controller?.startImageStream(_processImage);

        // Rule: 5 seconds max grace period for camera mode
        if (timeGone.inSeconds > 5) {
          _removeShield();
        }
      }
    }
  }

  void _removeShield() {
    setState(() => _shields--);
    if (_shields < 0) {
      _failProtocol("Visual Contact Lost: You left the app.");
    } else {
      _showWarning("⚠️ SHIELD LOST! Keep the app open!");
    }
  }

  // =================================================
  // 📷 CAMERA & AI LOOP
  // =================================================
  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();

    // Find front camera
    _frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      _frontCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    if (!mounted) return;

    // Start AI Loop
    _controller!.startImageStream(_processImage);
    setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || _failed || _controller == null) return;
    _isProcessing = true;

    try {
      final inputImage = CameraUtils.convertCameraImage(image, _frontCamera!);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        // Rule 1: Ghost Penalty (Target Lost for > 10s)
        if (_calculator.secondsSinceLastRep > 10 && _calculator.reps > 0) {
          if (mounted) setState(() => _statusMessage = "⚠️ TARGET LOST: RETURN TO FRAME");
        }
      } else {
        final pose = poses.first;

        // CHECK REPS
        bool isRep = _calculator.checkPushupRep(pose);

        if (mounted) {
          setState(() {
            _statusMessage = "TRACKING ACTIVE";

            // Rule 2: Laziness Penalty (Time Under Tension)
            // Allow 15s rest at top
            if (_calculator.secondsSinceLastRep > 15 && _calculator.reps > 0) {
              _failProtocol("Muscle Failure: Rest period exceeded (15s).");
            }
          });

          if (isRep) {
            HapticFeedback.heavyImpact(); // Physical confirm
          }
        }
      }
    } catch (e) {
      debugPrint("AI Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _failProtocol(String reason) {
    if (_failed) return;
    setState(() {
      _failed = true;
      _failReason = reason;
    });
    // Cut the feed
    _controller?.stopImageStream();
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orangeAccent, duration: const Duration(seconds: 2)),
    );
  }

  // =================================================
  // 🎨 UI BUILDER
  // =================================================
  @override
  Widget build(BuildContext context) {
    if (_failed) return _buildFailScreen();

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CAMERA FEED (Full Screen)
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),

          // 2. HUD OVERLAY
          SafeArea(
            child: Column(
              children: [
                // Top Status Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShields(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.greenAccent.withOpacity(0.5))
                        ),
                        child: Text(_statusMessage,
                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)
                        ),
                      )
                    ],
                  ),
                ),

                const Spacer(),

                // REP COUNTER (Huge)
                Text(
                  "${_calculator.reps}",
                  style: const TextStyle(
                      fontSize: 140,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 20, color: Colors.black)]
                  ),
                ),
                Text(
                    widget.taskName.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)]
                    )
                ),

                const SizedBox(height: 50),

                // FINISH BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.9),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("FINISH SET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5))
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShields() {
    return Row(
      children: List.generate(3, (index) {
        bool isActive = index < _shields;
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Icon(
            isActive ? Icons.shield : Icons.shield_outlined,
            color: isActive ? Colors.blueAccent : Colors.white30,
            size: 28,
          ),
        );
      }),
    );
  }

  Widget _buildFailScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0000),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 80),
              const SizedBox(height: 20),
              const Text("TRAINING FAILED", style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text(_failReason, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),

              const SizedBox(height: 20),
              // THE CONSEQUENCE UI
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Text("PENALTY: -10 HP", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ACCEPT DEFEAT", style: TextStyle(color: Colors.white))
              )
            ],
          ),
        ),
      ),
    );
  }
}