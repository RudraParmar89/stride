import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Glitch-free ring
import 'dart:async';
import 'dart:ui'; // For FontFeature

// Import Notification Service
import '../services/notification_service.dart';

class ClockScreen extends StatefulWidget {
  final int initialTabIndex;

  const ClockScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0B0B15);
    const Color primary = Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "TEMPORAL SYSTEM",
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelColor: primary,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          tabs: const [
            Tab(text: "FOCUS"),
            Tab(text: "ALARM"),
            Tab(text: "STOPWATCH"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FocusTimerTab(),
          AlarmTab(),
          StopwatchTab(),
        ],
      ),
    );
  }
}

// =========================================================
// 1. FOCUS TIMER TAB (ENHANCED)
// =========================================================
class FocusTimerTab extends StatefulWidget {
  const FocusTimerTab({super.key});

  @override
  State<FocusTimerTab> createState() => _FocusTimerTabState();
}

class _FocusTimerTabState extends State<FocusTimerTab> {
  Timer? _timer;
  int _initialSeconds = 1500; // 25 min default
  int _remainingSeconds = 1500;
  bool _isRunning = false;
  String _selectedTag = "Deep Work"; // Task Linking

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopTimer();
        _showCompletionDialog(); // XP Reward
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _remainingSeconds = _initialSeconds);
  }

  // XP Reward System
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("MISSION COMPLETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF00D2D3).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF00D2D3), size: 48),
            ),
            const SizedBox(height: 24),
            Text("You maintained focus on '$_selectedTag'.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            const Text("+150 XP", style: TextStyle(color: Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("CLAIM REWARD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _editDuration() async {
    _stopTimer();
    int? selectedMinutes = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempMin = _initialSeconds ~/ 60;
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text("Set Focus Duration", style: TextStyle(color: Colors.white)),
          content: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              suffixText: "min",
              suffixStyle: TextStyle(color: Colors.white54, fontSize: 16),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D2D3))),
            ),
            onChanged: (val) => tempMin = int.tryParse(val) ?? 25,
          ),
          actions: [
            TextButton(child: const Text("CANCEL"), onPressed: () => Navigator.pop(context)),
            TextButton(
              child: const Text("CONFIRM", style: TextStyle(color: Color(0xFF00D2D3), fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context, tempMin),
            ),
          ],
        );
      },
    );

    if (selectedMinutes != null && selectedMinutes > 0) {
      setState(() {
        _initialSeconds = selectedMinutes * 60;
        _remainingSeconds = _initialSeconds;
      });
    }
  }

  String _formatTime(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double percent = _remainingSeconds / (_initialSeconds == 0 ? 1 : _initialSeconds);

    // Focus Mode Background (Subtle shift when active)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: _isRunning ? const Color(0xFF05050A) : Colors.transparent, // Darker when running
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Task Linking Dropdown
          Container(
            margin: const EdgeInsets.only(bottom: 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTag,
                dropdownColor: const Color(0xFF1E1E2C),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                items: ["General Focus", "Deep Work", "Training", "Reading", "Meditation"]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: _isRunning ? null : (val) => setState(() => _selectedTag = val!),
              ),
            ),
          ),

          // Glitch-Free CircularPercentIndicator
          CircularPercentIndicator(
            radius: 130.0,
            lineWidth: 15.0,
            percent: percent,
            animation: true,
            animateFromLastPercent: true,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.white.withOpacity(0.05),
            linearGradient: const LinearGradient(
              colors: [Color(0xFF00D2D3), Color(0xFF6C63FF)], // Cyan to Purple Gradient
            ),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFeatures: [FontFeature.tabularFigures()]
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRunning ? "SYSTEM ACTIVE" : "SYSTEM PAUSED",
                  style: TextStyle(
                      color: _isRunning ? const Color(0xFF00D2D3) : Colors.white54,
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(Icons.refresh, Colors.white24, _resetTimer),
              const SizedBox(width: 24),
              _buildButton(
                  _isRunning ? Icons.pause : Icons.play_arrow_rounded,
                  const Color(0xFF00D2D3),
                  _isRunning ? _stopTimer : _startTimer,
                  isBig: true,
                  isGlowing: _isRunning
              ),
              const SizedBox(width: 24),
              _buildButton(Icons.edit_outlined, Colors.white24, _editDuration),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, Color color, VoidCallback onTap, {bool isBig = false, bool isGlowing = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isBig ? 24 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(isBig ? 0.2 : 0.1),
          shape: BoxShape.circle,
          border: isBig ? Border.all(color: color, width: 2) : null,
          boxShadow: isGlowing
              ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)]
              : [],
        ),
        child: Icon(icon, color: isBig ? color : Colors.white, size: isBig ? 32 : 24),
      ),
    );
  }
}

// =========================================================
// 2. ALARM TAB (FUNCTIONAL & FIXED FAB)
// =========================================================
class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  List<Map<String, dynamic>> alarms = [
    {'id': 1, 'time': const TimeOfDay(hour: 6, minute: 0), 'label': 'Morning Training', 'isActive': true},
  ];

  void _toggleAlarm(int index, bool val) {
    setState(() => alarms[index]['isActive'] = val);
    final alarm = alarms[index];
    if (val) {
      NotificationService.scheduleAlarm(id: alarm['id'], title: alarm['label'], time: alarm['time']);
    } else {
      NotificationService.cancelNotification(alarm['id']);
    }
  }

  void _addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFF6C63FF), onPrimary: Colors.white, surface: Color(0xFF1E1E2C), onSurface: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      setState(() {
        alarms.add({'id': newId, 'time': picked, 'label': 'New Mission', 'isActive': true});
      });
      NotificationService.scheduleAlarm(id: newId, title: "New Mission", time: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // FIX: Added Padding to lift FAB above Bottom Navigation Bar
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: _addAlarm,
          backgroundColor: const Color(0xFF6C63FF),
          child: const Icon(Icons.add_alarm, color: Colors.white),
        ),
      ),

      body: alarms.isEmpty
          ? Center(child: Text("NO ALARMS SET", style: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 2, fontWeight: FontWeight.bold)))
          : ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: alarms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          final time = alarm['time'] as TimeOfDay;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: alarm['isActive'] ? const Color(0xFF6C63FF).withOpacity(0.5) : Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}", style: TextStyle(color: alarm['isActive'] ? Colors.white : Colors.white54, fontSize: 32, fontWeight: FontWeight.bold)),
                    Text(alarm['label'], style: TextStyle(color: alarm['isActive'] ? const Color(0xFF6C63FF) : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Switch(
                  value: alarm['isActive'],
                  activeColor: const Color(0xFF6C63FF),
                  onChanged: (val) => _toggleAlarm(index, val),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =========================================================
// 3. STOPWATCH TAB (FUNCTIONAL)
// =========================================================
class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    if (_stopwatch.isRunning) _timer.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
    setState(() {});
  }

  void _resetStopwatch() {
    _stopStopwatch();
    _stopwatch.reset();
    setState(() {});
  }

  String _formatStopwatchTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate();

    String minStr = minutes.toString().padLeft(2, '0');
    String secStr = seconds.toString().padLeft(2, '0');
    String hunStr = hundreds.toString().padLeft(2, '0');

    return "$minStr:$secStr.$hunStr";
  }

  @override
  Widget build(BuildContext context) {
    final bool isRunning = _stopwatch.isRunning;
    const Color accentOrange = Color(0xFFFF9F43);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatStopwatchTime(_stopwatch.elapsedMilliseconds),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _resetStopwatch,
              child: Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: const Icon(Icons.stop, color: Colors.white)),
            ),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: isRunning ? _stopStopwatch : _startStopwatch,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: accentOrange.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: accentOrange, width: 2), boxShadow: [BoxShadow(color: accentOrange.withOpacity(0.4), blurRadius: 20)]),
                child: Icon(isRunning ? Icons.pause : Icons.play_arrow, color: accentOrange, size: 40),
              ),
            ),
          ],
        ),
      ],
    );
  }
}