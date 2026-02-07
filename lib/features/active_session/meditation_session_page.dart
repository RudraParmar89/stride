import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart'; // 🎵 IMPORT AUDIO PACKAGE
import '../../theme/theme_manager.dart';

class MeditationSessionPage extends StatefulWidget {
  final String taskName;
  final int durationMinutes;

  const MeditationSessionPage({
    super.key,
    required this.taskName,
    this.durationMinutes = 10
  });

  @override
  State<MeditationSessionPage> createState() => _MeditationSessionPageState();
}

class _MeditationSessionPageState extends State<MeditationSessionPage> with TickerProviderStateMixin {
  // 🎵 AUDIO PLAYER
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  late AnimationController _breathingController;
  Timer? _timer;
  late int _totalSeconds;
  late int _remainingSeconds;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _startTimer();
    _initAudio(); // 🎵 PREPARE AUDIO
  }

  // 🎵 SETUP AUDIO
  Future<void> _initAudio() async {
    // Set to loop so it never stops during meditation
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // Prepare the file (don't play yet, wait for user or start immediately if you prefer)
    await _audioPlayer.setSource(AssetSource('sounds/meditation.mp3'));
  }

  // 🎵 TOGGLE MUSIC
  void _toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _finishSession();
        }
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _breathingController.stop();
      } else {
        _breathingController.repeat(reverse: true);
      }
    });
  }

  void _finishSession() {
    _timer?.cancel();
    _audioPlayer.stop(); // 🛑 STOP MUSIC

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeManager().cardColor,
        title: Text("Namaste 🙏", style: TextStyle(color: ThemeManager().textColor)),
        content: Text(
          "Mindfulness session complete. You've earned this peace.",
          style: TextStyle(color: ThemeManager().subText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text("Complete Task", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int min = totalSeconds ~/ 60;
    int sec = totalSeconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _audioPlayer.dispose(); // 🧹 CLEANUP MEMORY
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager();
    double percent = 1.0 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      backgroundColor: theme.bgColor,
      body: Stack(
        children: [
          // 🌌 Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  theme.accentColor.withOpacity(0.15),
                  theme.bgColor,
                ],
                center: Alignment.center,
                radius: 0.8,
              ),
            ),
          ),

          // 🎵 MUSIC CONTROL (Top Right)
          Positioned(
            top: 50, right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: IconButton(
                icon: Icon(
                  _isMusicPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
                  color: _isMusicPlaying ? theme.accentColor : theme.subText,
                ),
                onPressed: _toggleMusic,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isPaused ? "PAUSED" : "BREATHE",
                  style: TextStyle(
                      color: theme.subText,
                      letterSpacing: 4.0,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 40),

                // ⭕ Timer
                AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_breathingController.value * 0.1),
                      child: CircularPercentIndicator(
                        radius: 120.0,
                        lineWidth: 10.0,
                        percent: percent.clamp(0.0, 1.0),
                        center: Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 40,
                            fontWeight: FontWeight.w200,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        progressColor: theme.accentColor,
                        backgroundColor: theme.subText.withOpacity(0.1),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animateFromLastPercent: true,
                        animationDuration: 1000,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // ⏯️ Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 58,
                      icon: Icon(
                        _isPaused ? Icons.play_circle_fill_rounded : Icons.pause_circle_filled_rounded,
                        color: theme.textColor,
                      ),
                      onPressed: _togglePause,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("End Session", style: TextStyle(color: theme.subText.withOpacity(0.5))),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}