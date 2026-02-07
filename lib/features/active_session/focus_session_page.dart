import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../controllers/xp_controller.dart';

class FocusSessionPage extends StatefulWidget {
  final String taskName;
  final int? durationMinutes; // Task-specific duration (e.g., 17 for lower body)
  const FocusSessionPage({
    super.key,
    required this.taskName,
    this.durationMinutes,
  });

  @override
  State<FocusSessionPage> createState() => _FocusSessionPageState();
}

class _FocusSessionPageState extends State<FocusSessionPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  // ================= CONFIGURATION =================
  static const int _maxStepsAllowed = 10;
  static const int _graceSecondsLimit = 90;
  static const int _maxShields = 3;
  static const int _focusMinutesPerBlock = 30;
  static const int _breakMinutesPerBlock = 5;

  // ================= TIMER STATE =================
  late AnimationController _timerAnimationController;
  late Animation<double> _timerAnimation;
  
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSessionSeconds = 0;
  bool _isRunning = false;
  bool _isBreak = false;
  int _sessionCount = 0;
  int _targetSessions = 0;
  late int _sessionDuration; // Based on task duration

  // ================= ANTI-CHEAT STATE =================
  late Stream<StepCount> _stepCountStream;
  int _initialSteps = -1;
  int _stepsTaken = 0;

  int _shields = _maxShields;
  DateTime? _pausedAt;

  bool _failed = false;
  String _failReason = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeTimer();
    _initPedometer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timerAnimationController.dispose();
    super.dispose();
  }

  // ================= TIMER INITIALIZATION =================
  void _initializeTimer() {
    // Use task-specific duration or fall back to level-based
    if (widget.durationMinutes != null) {
      _sessionDuration = widget.durationMinutes!;
      _targetSessions = 1; // Just one session for task-based timers
    } else {
      // Study session: based on level with 30-min blocks
      final xpController = context.read<XpController>();
      _targetSessions = _getTargetSessionsByLevel(xpController.level);
      _sessionDuration = _focusMinutesPerBlock;
    }
    
    _remainingSeconds = _sessionDuration * 60;
    _totalSessionSeconds = _remainingSeconds;
    
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSessionSeconds),
    );

    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(_timerAnimationController);
  }

  int _getTargetSessionsByLevel(int level) {
    if (level <= 2) return 2; // 60 min
    if (level <= 4) return 4; // 120 min
    if (level <= 6) return 6; // 180 min
    if (level <= 8) return 8; // 240 min
    if (level <= 10) return 10; // 300 min
    return 12; // 360 min max
  }

  // ================= TIMER CONTROL =================
  void _startTimer() {
    if (_remainingSeconds > 0) {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
      _timerAnimationController.forward(
        from: (_totalSessionSeconds - _remainingSeconds) / _totalSessionSeconds,
      );
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timerAnimationController.reset();
    
    setState(() {
      _isRunning = false;
      
      if (_isBreak) {
        _remainingSeconds = _breakMinutesPerBlock * 60;
        _totalSessionSeconds = _remainingSeconds;
      } else {
        _remainingSeconds = _sessionDuration * 60;
        _totalSessionSeconds = _remainingSeconds;
      }
    });
    
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSessionSeconds),
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(_timerAnimationController);
  }

  void _tick(Timer timer) {
    if (_remainingSeconds > 0) {
      setState(() => _remainingSeconds--);
    } else {
      _sessionComplete();
    }
  }

  void _sessionComplete() {
    _timer?.cancel();
    _timerAnimationController.stop();

    if (!_isBreak) {
      setState(() {
        _sessionCount++;
        _isBreak = true;
      });
      _showDialog(
        title: "Break Time! 🧘",
        message: "Take 5 minutes to recharge.",
        onContinue: () {
          _resetTimer();
          _startTimer();
        },
      );
    } else {
      if (_sessionCount < _targetSessions) {
        setState(() => _isBreak = false);
        _showDialog(
          title: "Ready to Continue? 🎯",
          message: "Next $_sessionDuration-minute session",
          onContinue: () {
            _resetTimer();
            _startTimer();
          },
        );
      } else {
        Navigator.pop(context, true); // Success!
      }
    }
    _resetTimer();
  }

  void _showDialog({
    required String title,
    required String message,
    required VoidCallback onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20)),
        content: Text(message, style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent.withOpacity(0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: const Text("Continue", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // =================================================
  // 🛡️ CORE LOGIC: APP BACKGROUND DETECTION (STRIKE SYSTEM)
  // =================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_failed) return;

    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    }
    else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final timeGone = DateTime.now().difference(_pausedAt!);
        _pausedAt = null;

        if (timeGone.inSeconds > _graceSecondsLimit) {
          _failProtocol("Distraction Detected: You were gone for ${timeGone.inSeconds}s. Limit is ${_graceSecondsLimit}s.");
        } else {
          _removeShield();
        }
      }
    }
  }

  void _removeShield() {
    setState(() {
      _shields--;
    });

    if (_shields < 0) {
      _failProtocol("Shields Depleted: Too many distractions.");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ SHIELD BROKEN! ${_shields + 1} remaining."),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // =================================================
  // 🛡️ CORE LOGIC: ANCHOR (PEDOMETER 7M LIMIT)
  // =================================================
  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen((StepCount event) {
      if (_failed) return;

      if (_initialSteps == -1) {
        setState(() => _initialSteps = event.steps);
      }

      setState(() {
        _stepsTaken = event.steps - _initialSteps;
      });

      if (_stepsTaken > _maxStepsAllowed) {
        _failProtocol("Position Abandoned: You moved more than 7 meters.");
      }
    }).onError((error) {
      debugPrint("Pedometer Error: $error");
    });
  }

  void _failProtocol(String reason) {
    if (_failed) return;
    setState(() {
      _failed = true;
      _failReason = reason;
    });
    _timer?.cancel();
  }

  // ================= FORMAT TIME HELPER =================
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // =================================================
  // ELEGANT MINIMAL UI
  // =================================================
  @override
  Widget build(BuildContext context) {
    // 🔴 FAIL SCREEN
    if (_failed) {
      return Scaffold(
        backgroundColor: const Color(0xFF0a0a0a),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 80),
                const SizedBox(height: 20),
                const Text("MISSION FAILED", style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text(_failReason, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("EXIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      );
    }

    // 🟢 ELEGANT MINIMAL TIMER SCREEN
    final timerColor = _isBreak ? Colors.cyan : Colors.greenAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: SafeArea(
        child: Column(
          children: [
            // --- MINIMAL TOP BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task name
                  Text(
                    widget.taskName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Session progress (minimal)
                  if (_targetSessions > 1)
                    Text(
                      "Session ${_sessionCount + 1} / $_targetSessions",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // --- CENTER: ENHANCED TIMER WITH SHIELD ---
            Center(
              child: AnimatedBuilder(
                animation: _timerAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shield backdrop (animated glow)
                      if (!_isBreak)
                        CustomPaint(
                          painter: ShieldGlowPainter(
                            progress: _timerAnimation.value,
                            shieldCount: _shields,
                          ),
                          size: const Size(320, 320),
                        ),

                      // Gradient background circle
                      CustomPaint(
                        painter: EllegantTimerPainter(
                          progress: _timerAnimation.value,
                          color: timerColor,
                        ),
                        size: const Size(280, 280),
                      ),
                      
                      // Timer content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status text
                          Text(
                            _isBreak ? "BREAK" : "FOCUS",
                            style: TextStyle(
                              color: timerColor.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Timer display
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                              color: timerColor,
                              fontSize: 76,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                            ),
                          ),
                        ],
                      ),
                      
                      // Shield indicator (top-right)
                      if (!_isBreak)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _buildShieldBadge(),
                        ),
                    ],
                  );
                },
              ),
            ),

            const Spacer(),

            // --- MINIMAL ANTI-CHEAT (COMPACT) ---
            if (!_isBreak)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildMinimalAntiCheat(),
              ),

            // --- ACTION BUTTON (LARGE, CENTERED) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: _isRunning
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          "EXIT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: timerColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _startTimer,
                        child: Text(
                          "START",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.black,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SHIELD BADGE WIDGET =================
  Widget _buildShieldBadge() {
    final isCompromised = _shields < _maxShields;
    final shieldColor = isCompromised ? Colors.orange : Colors.greenAccent;
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: shieldColor.withValues(alpha: 0.15),
        border: Border.all(
          color: shieldColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield icon
          Icon(
            Icons.security,
            color: shieldColor,
            size: 28,
          ),
          // Shield count indicator
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: shieldColor, width: 1.5),
              ),
              child: Center(
                child: Text(
                  "$_shields",
                  style: TextStyle(
                    color: shieldColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ENHANCED ANTI-CHEAT WIDGET =================
  Widget _buildMinimalAntiCheat() {
    final integrityPercent = (_shields / _maxShields * 100).toInt();
    final isGood = integrityPercent >= 70;
    
    return Column(
      children: [
        // Title
        Text(
          "INTEGRITY CHECK",
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        
        // Main status row
        Row(
          children: [
            // Integrity indicator (enhanced)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isGood ? Colors.greenAccent : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isGood ? Colors.greenAccent : Colors.orange).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isGood ? Icons.verified : Icons.warning_rounded,
                      size: 20,
                      color: isGood ? Colors.greenAccent : Colors.orange,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$integrityPercent%",
                      style: TextStyle(
                        color: isGood ? Colors.greenAccent : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Integrity",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Anchor indicator (enhanced)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_stepsTaken > 7 ? Colors.orange : Colors.greenAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_stepsTaken > 7 ? Colors.orange : Colors.greenAccent).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: _stepsTaken > 7 ? Colors.orange : Colors.greenAccent,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$_stepsTaken/10",
                      style: TextStyle(
                        color: _stepsTaken > 7 ? Colors.orange : Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Anchor",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Shields indicator (enhanced)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.cyan.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 20,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$_shields/$_maxShields",
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Shields",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================= ELEGANT TIMER PAINTER =================
class EllegantTimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  EllegantTimerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Outer background circle (very subtle)
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc with elegant stroke
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      progress * 2 * 3.14159,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(EllegantTimerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ================= SHIELD GLOW PAINTER =================
class ShieldGlowPainter extends CustomPainter {
  final double progress;
  final int shieldCount;

  ShieldGlowPainter({
    required this.progress,
    required this.shieldCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Shield glow (animated based on shield count)
    final glowColor = shieldCount >= 3
        ? Colors.greenAccent
        : shieldCount >= 2
            ? Colors.orange
            : Colors.redAccent;

    // Outer glow (fades)
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.15 * (1 - progress.abs()))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

    canvas.drawCircle(center, radius + 8, glowPaint);

    // Inner pulse ring
    final pulsePaint = Paint()
      ..color = glowColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 4, pulsePaint);
  }

  @override
  bool shouldRepaint(ShieldGlowPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.shieldCount != shieldCount;
}