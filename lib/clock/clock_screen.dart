import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'dart:ui';

// Import Theme
import '../theme/theme_manager.dart';

// Import Notification Service (Keep your existing file)
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
    // 1. LISTEN TO THEME
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Scaffold(
          backgroundColor: theme.bgColor, // <--- DYNAMIC BG
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              "TEMPORAL SYSTEM",
              style: TextStyle(
                  color: theme.subText, // <--- DYNAMIC SUBTEXT
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.accentColor, // <--- DYNAMIC ACCENT
              labelColor: theme.accentColor,
              unselectedLabelColor: theme.subText,
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
      },
    );
  }
}

// =========================================================
// 1. FOCUS TIMER TAB (THEMED)
// =========================================================
class FocusTimerTab extends StatefulWidget {
  const FocusTimerTab({super.key});

  @override
  State<FocusTimerTab> createState() => _FocusTimerTabState();
}

class _FocusTimerTabState extends State<FocusTimerTab> {
  Timer? _timer;
  int _initialSeconds = 1500;
  int _remainingSeconds = 1500;
  bool _isRunning = false;
  String _selectedTag = "Deep Work";

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
        _showCompletionDialog();
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

  // XP Reward System (Themed)
  void _showCompletionDialog() {
    final theme = ThemeManager(); // Access singleton directly for dialogs

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
            child: Text(
                "MISSION COMPLETE",
                style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.accentColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.verified_rounded, color: theme.accentColor, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
                "You maintained focus on '$_selectedTag'.",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.subText)
            ),
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
                backgroundColor: theme.accentColor,
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
    final theme = ThemeManager();

    int? selectedMinutes = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempMin = _initialSeconds ~/ 60;
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text("Set Focus Duration", style: TextStyle(color: theme.textColor)),
          content: TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: "min",
              suffixStyle: TextStyle(color: theme.subText, fontSize: 16),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.subText)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.accentColor)),
            ),
            onChanged: (val) => tempMin = int.tryParse(val) ?? 25,
          ),
          actions: [
            TextButton(
                child: Text("CANCEL", style: TextStyle(color: theme.subText)),
                onPressed: () => Navigator.pop(context)
            ),
            TextButton(
              child: Text("CONFIRM", style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold)),
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
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();
        double percent = _remainingSeconds / (_initialSeconds == 0 ? 1 : _initialSeconds);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          // Subtle tint when running, clean when not
          color: _isRunning ? theme.accentColor.withOpacity(0.05) : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Task Linking Dropdown
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: theme.textColor.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTag,
                    dropdownColor: theme.cardColor,
                    icon: Icon(Icons.arrow_drop_down, color: theme.subText),
                    style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14),
                    items: ["General Focus", "Deep Work", "Training", "Reading", "Meditation"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: _isRunning ? null : (val) => setState(() => _selectedTag = val!),
                  ),
                ),
              ),

              // Circular Progress
              CircularPercentIndicator(
                radius: 130.0,
                lineWidth: 15.0,
                percent: percent,
                animation: true,
                animateFromLastPercent: true,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: theme.textColor.withOpacity(0.05),
                linearGradient: LinearGradient(
                  colors: [theme.accentColor, theme.accentColor.withOpacity(0.6)],
                ),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                          color: theme.textColor,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFeatures: const [FontFeature.tabularFigures()]
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning ? "SYSTEM ACTIVE" : "SYSTEM PAUSED",
                      style: TextStyle(
                          color: _isRunning ? theme.accentColor : theme.subText,
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
                  _buildButton(theme, Icons.refresh, theme.subText, _resetTimer),
                  const SizedBox(width: 24),
                  _buildButton(
                      theme,
                      _isRunning ? Icons.pause : Icons.play_arrow_rounded,
                      theme.accentColor,
                      _isRunning ? _stopTimer : _startTimer,
                      isBig: true,
                      isGlowing: _isRunning
                  ),
                  const SizedBox(width: 24),
                  _buildButton(theme, Icons.edit_outlined, theme.subText, _editDuration),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(ThemeManager theme, IconData icon, Color color, VoidCallback onTap, {bool isBig = false, bool isGlowing = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isBig ? 24 : 16),
        decoration: BoxDecoration(
          color: isBig ? theme.cardColor : theme.cardColor.withOpacity(0.5),
          shape: BoxShape.circle,
          border: isBig ? Border.all(color: color, width: 2) : null,
          boxShadow: isGlowing
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)]
              : theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Icon(icon, color: color, size: isBig ? 32 : 24),
      ),
    );
  }
}

// =========================================================
// 2. ALARM TAB (THEMED)
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
    final theme = ThemeManager();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Theme the TimePicker
        return Theme(
          data: theme.isDark
              ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: theme.accentColor, onPrimary: Colors.white, surface: theme.cardColor, onSurface: Colors.white),
          )
              : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: theme.accentColor, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
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
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FloatingActionButton(
              onPressed: _addAlarm,
              backgroundColor: theme.accentColor,
              child: const Icon(Icons.add_alarm, color: Colors.white),
            ),
          ),
          body: alarms.isEmpty
              ? Center(child: Text("NO ALARMS SET", style: TextStyle(color: theme.subText, letterSpacing: 2, fontWeight: FontWeight.bold)))
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
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: alarm['isActive'] ? theme.accentColor.withOpacity(0.5) : theme.textColor.withOpacity(0.05)),
                  boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}",
                            style: TextStyle(color: alarm['isActive'] ? theme.textColor : theme.subText, fontSize: 32, fontWeight: FontWeight.bold)
                        ),
                        Text(
                            alarm['label'],
                            style: TextStyle(color: alarm['isActive'] ? theme.accentColor : theme.subText, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    Switch(
                      value: alarm['isActive'],
                      activeColor: theme.accentColor,
                      onChanged: (val) => _toggleAlarm(index, val),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// =========================================================
// 3. STOPWATCH TAB (THEMED)
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
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();
        final bool isRunning = _stopwatch.isRunning;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatStopwatchTime(_stopwatch.elapsedMilliseconds),
              style: TextStyle(
                color: theme.textColor, // <--- DYNAMIC COLOR
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _resetStopwatch,
                  child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: theme.textColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.stop, color: theme.textColor)
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: isRunning ? _stopStopwatch : _startStopwatch,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                        color: theme.accentColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.accentColor, width: 2),
                        boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.4), blurRadius: 20)]
                    ),
                    child: Icon(isRunning ? Icons.pause : Icons.play_arrow, color: theme.accentColor, size: 40),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}