import 'dart:ui';
import 'dart:math'; // ✅ Required for Random
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ RELATIVE IMPORTS
import '../../theme/theme_manager.dart';
import '../models/user_profile.dart';
import '../services/task_generator_service.dart';
import '../services/sync_service.dart';
import '../models/task.dart';

class IdentityProtocolScreen extends StatefulWidget {
  const IdentityProtocolScreen({super.key});

  @override
  State<IdentityProtocolScreen> createState() => _IdentityProtocolScreenState();
}

class _IdentityProtocolScreenState extends State<IdentityProtocolScreen> {
  // State Variables
  String _name = '';
  int _age = 18;
  String _gender = 'Male';
  double _weight = 70;
  double _height = 175;
  double _currentStudy = 2;
  double _goalStudy = 6;
  String _bodyType = 'Average';

  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- 🎲 RANDOM NAME GENERATOR ---
  String _generateCodename() {
    final random = Random();
    const prefixes = [
      'Spectre', 'Viper', 'Ghost', 'Nomad',
      'Ronin', 'Shadow', 'Wraith', 'Cipher',
      'Echo', 'Titan', 'Omen', 'Vector'
    ];
    String prefix = prefixes[random.nextInt(prefixes.length)];
    int number = random.nextInt(100); // 00 to 99
    return '$prefix-${number.toString().padLeft(2, '0')}';
  }

  // --- INIT LOGIC ---
  void _finishInitialization() async {
    HapticFeedback.heavyImpact();
    final theme = Provider.of<ThemeManager>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: theme.accentColor),
      ),
    );

    try {
      // ✅ LOGIC: If name is empty, generate a random one
      String finalCallsign = _name.trim();
      if (finalCallsign.isEmpty) {
        finalCallsign = _generateCodename();
      }

      final user = UserProfile(
        callsign: finalCallsign, // Use the processed name
        age: _age,
        gender: _gender,
        weight: _weight,
        height: _height,
        currentStudyHours: _currentStudy,
        expectedGrindHours: _goalStudy,
        targetPhysique: _bodyType,
        startDate: DateTime.now(),
      );

      // Save Profile
      final userBox = Hive.box<UserProfile>('userBox');
      await userBox.put('currentUser', user);

      // Generate Tasks
      final tasks = TaskGeneratorService.generateDailyQuests(user, userLevel: 1);
      final taskBox = Hive.box<Task>('tasks');
      await taskBox.clear();
      for (final t in tasks) {
        await taskBox.put(t.id, t);
      }

      // Save Settings
      final settings = Hive.box('settingsBox');
      await settings.put('userName', finalCallsign);
      await settings.put('hasSeenOnboarding', true);

      // Cloud Sync
      if (FirebaseAuth.instance.currentUser != null) {
        SyncService.uploadData();
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close Dialog
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);

        // Optional: Show a snackbar telling them their new name
        if (_name.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Identity Assigned: $finalCallsign", style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: theme.accentColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Initialization Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FORCE LIGHT THEME COLORS
    const bgColor = Color(0xFFF2F2F7); // Apple-style Light Grey
    const cardColor = Colors.white;
    const textColor = Colors.black;
    const accentColor = Color(0xFF5E5CE6); // Indigo Purple Accent
    const subText = Color(0xFF8E8E93);

    // ✅ FORCE DARK STATUS BAR ICONS (Since background is light)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: bgColor, // Should be White or very light grey
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. AMBIENT BACKGROUND
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.08), // Reduced opacity for light mode
                boxShadow: [
                  BoxShadow(
                      color: accentColor.withOpacity(0.15),
                      blurRadius: 100,
                      spreadRadius: 50
                  )
                ],
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                _buildMinimalHeader(accentColor, subText),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBigInput(accentColor, textColor, subText),
                        const SizedBox(height: 30),
                        _buildSectionLabel("BIOMETRICS", subText),
                        _buildBiometricsCard(cardColor, subText, accentColor, textColor),
                        const SizedBox(height: 30),
                        _buildSectionLabel("PERFORMANCE TARGETS", subText),
                        _buildPerformanceCard(cardColor, subText, accentColor, textColor),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                _buildActionArea(cardColor, accentColor, subText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PREMIUM WIDGETS ====================

  Widget _buildMinimalHeader(Color accentColor, Color subText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.fingerprint, color: accentColor, size: 28),
          Text(
            "IDENTITY PROTOCOL",
            style: TextStyle(color: subText, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildBigInput(Color accentColor, Color textColor, Color subText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CALLSIGN", style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        TextField(
          controller: _nameController,
          style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          decoration: InputDecoration(
            // ✅ Updated Hint
            hintText: "Leave empty for random",
            hintStyle: TextStyle(color: subText.withOpacity(0.3), fontSize: 24),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => _name = v,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text, Color subText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: TextStyle(color: subText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  // --- CARD: BIOMETRICS ---
  Widget _buildBiometricsCard(Color cardColor, Color subText, Color accentColor, Color textColor) {
    return _buildGlassContainer(
      cardColor,
      textColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("GENDER", style: TextStyle(color: subText, fontSize: 12, fontWeight: FontWeight.bold)),
                Row(
                  children: ['Male', 'Female'].map((g) {
                    bool selected = _gender == g;
                    return GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? accentColor : Colors.transparent, // Transparent for unselected in light mode might need tweaking depending on background, trying transparent for now based on previous dark logic, but maybe a very light grey is better? Let's stick to accent vs transparent/bg color logic
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? Colors.transparent : textColor.withOpacity(0.1)),
                        ),
                        // Text color logic: White if selected, textColor (black) if not
                        child: Text(g, style: TextStyle(color: selected ? Colors.white : textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          _buildDivider(textColor),
          _buildCleanSlider("AGE", _age.toDouble(), 10, 90, "", (v) => setState(() => _age = v.toInt()), subText, accentColor, textColor),
          _buildDivider(textColor),
          _buildCleanSlider("WEIGHT", _weight, 40, 150, " kg", (v) => setState(() => _weight = v), subText, accentColor, textColor),
          _buildDivider(textColor),
          _buildCleanSlider("HEIGHT", _height, 140, 220, " cm", (v) => setState(() => _height = v), subText, accentColor, textColor),
          _buildDivider(textColor),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("BODY COMPOSITION", style: TextStyle(color: subText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: ['Skinny', 'Lean', 'Athletic', 'Lean-Muscular', 'Average', 'Heavy', 'Stocky', 'Obese'].map((t) {
                    bool active = _bodyType == t;
                    return GestureDetector(
                      onTap: () { HapticFeedback.selectionClick(); setState(() => _bodyType = t); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          // Active: Accent | Inactive: Very light grey/transparent with border
                          color: active ? textColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: active ? Colors.transparent : textColor.withOpacity(0.2)),
                        ),
                        // Text color: Bg color (whiteish) if active, textColor (black) if inactive
                        child: Text(t, style: TextStyle(color: active ? cardColor : textColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- CARD: PERFORMANCE ---
  Widget _buildPerformanceCard(Color cardColor, Color subText, Color accentColor, Color textColor) {
    return _buildGlassContainer(
      cardColor,
      textColor,
      child: Column(
        children: [
          _buildCleanSlider("CURRENT STUDY", _currentStudy, 0, 16, " hrs", (v) => setState(() => _currentStudy = v), subText, accentColor, textColor),
          _buildDivider(textColor),
          _buildCleanSlider("TARGET GOAL", _goalStudy, 0, 16, " hrs", (v) => setState(() => _goalStudy = v), subText, accentColor, textColor, isAccent: true),
        ],
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildGlassContainer(Color cardColor, Color textColor, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            // ✅ LIGHT MODE ADJUSTMENT: Whiter background, darker border
            color: cardColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: textColor.withOpacity(0.08), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildCleanSlider(String label, double val, double min, double max, String unit, Function(double) onChanged, Color subText, Color accentColor, Color textColor, {bool isAccent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: subText, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text("${val.toStringAsFixed(0)}$unit", style: TextStyle(color: isAccent ? accentColor : textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: isAccent ? accentColor : textColor,
                inactiveTrackColor: textColor.withOpacity(0.1),
                thumbColor: isAccent ? accentColor : textColor,
                overlayShape: SliderComponentShape.noOverlay,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 4,
              ),
              child: Slider(value: val, min: min, max: max, onChanged: (v) {
                if ((v - val).abs() > 0.5) HapticFeedback.selectionClick();
                onChanged(v);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color textColor) => Divider(height: 1, color: textColor.withOpacity(0.05));

  Widget _buildActionArea(Color cardColor, Color accentColor, Color subText) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: HoldToBeginButton(onComplete: _finishInitialization, cardColor: cardColor, accentColor: accentColor, subText: subText),
    );
  }
}

// ================= BIOMETRIC LAUNCH BUTTON =================
class HoldToBeginButton extends StatefulWidget {
  final VoidCallback onComplete;
  final Color cardColor;
  final Color accentColor;
  final Color subText;
  const HoldToBeginButton({super.key, required this.onComplete, required this.cardColor, required this.accentColor, required this.subText});

  @override
  State<HoldToBeginButton> createState() => _HoldToBeginButtonState();
}

class _HoldToBeginButtonState extends State<HoldToBeginButton> with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();

    // 1. PROGRESS (The Hold)
    _progressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500)
    )..addListener(() {
      setState(() {});
      if (_progressCtrl.value > 0.0 && _progressCtrl.value % 0.1 < 0.02) {
        HapticFeedback.selectionClick();
      }
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onComplete();
      }
    });

    // 2. PULSE (Idle)
    _pulseCtrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2)
    )..repeat(reverse: true);

    // 3. SCALE (Press)
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95, upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown() {
    HapticFeedback.mediumImpact();
    _scaleCtrl.reverse();
    _progressCtrl.forward();
  }

  void _onTapUp() {
    if (_progressCtrl.status != AnimationStatus.completed) {
      _scaleCtrl.forward();
      _progressCtrl.reverse();
    }
  }

  double _getShake() {
    if (_progressCtrl.value < 0.1) return 0.0;
    double intensity = _progressCtrl.value * 3.0;
    return (DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 1 : -1) * intensity;
  }

  @override
  Widget build(BuildContext context) {
    double progress = _progressCtrl.value;
    bool isComplete = progress >= 1.0;

    // ✅ LIGHT THEME COLORS FOR BUTTON
    final accent = widget.accentColor;
    final bg = widget.cardColor; // White/Light Grey
    final textIdle = widget.subText;
    final textActive = Colors.white;

    // ✅ FORCE BLACK TEXT COLOR
    const textColor = Colors.black;

    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapUp(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressCtrl, _scaleCtrl, _pulseCtrl]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_getShake(), 0),
            child: Transform.scale(
              scale: _scaleCtrl.value,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _progressCtrl.isAnimating ? accent : textColor.withOpacity(0.1),
                    width: _progressCtrl.isAnimating ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (_progressCtrl.isAnimating)
                      BoxShadow(
                        color: accent.withOpacity(0.4 * progress),
                        blurRadius: 15 * progress,
                        offset: const Offset(0, 5),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), // Soft shadow for light mode
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // LAYER 1: IDLE TEXT
                      Center(
                        child: Text(
                          "HOLD TO INITIALIZE",
                          style: TextStyle(
                            color: textIdle.withOpacity(0.5 + (_pulseCtrl.value * 0.5)),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      // LAYER 2: FILL + ACTIVE TEXT
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isComplete ? Colors.white : accent,
                              ),
                              child: Center(
                                child: Text(
                                  isComplete ? "SUCCESS" : "SYSTEM SYNCING...",
                                  style: TextStyle(
                                    color: isComplete ? accent : textActive,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0 + (progress * 1),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // LAYER 3: SCAN LINE (White)
                      if (_progressCtrl.isAnimating && !isComplete)
                        Positioned(
                          left: (MediaQuery.of(context).size.width - 48) * progress,
                          top: 0, bottom: 0,
                          child: Container(
                            width: 2,
                            decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 1)],
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}