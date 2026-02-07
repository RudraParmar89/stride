import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart'; // ✅ Added for saving data

// Import Theme
import '../theme/theme_manager.dart';

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
    return Consumer<ThemeManager>(
      builder: (context, theme, child) {

        return Scaffold(
          backgroundColor: theme.bgColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // --- SPACER ---
                const SizedBox(height: 30),

                // --- HEADER ---
                Center(
                  child: Text(
                    "TEMPORAL SYSTEM",
                    style: TextStyle(
                        color: theme.subText,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- TAB BAR ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: theme.textColor.withOpacity(0.05)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.accentColor,
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.3), blurRadius: 10)],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: theme.subText,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                    tabs: const [
                      Tab(text: "FOCUS"),
                      Tab(text: "ALARM"),
                      Tab(text: "STOPWATCH"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- TAB VIEW ---
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      FocusTimerTab(),
                      AlarmTab(),
                      StopwatchTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================
// 1. FOCUS TIMER TAB (Fixed: Keeps state alive)
// =========================================================
class FocusTimerTab extends StatefulWidget {
  const FocusTimerTab({super.key});

  @override
  State<FocusTimerTab> createState() => _FocusTimerTabState();
}

class _FocusTimerTabState extends State<FocusTimerTab> with AutomaticKeepAliveClientMixin {
  // ✅ Keeps timer running when switching tabs
  @override
  bool get wantKeepAlive => true;

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

  void _showCompletionDialog() {
    final theme = ThemeManager();
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
    super.build(context); // ✅ Required for KeepAlive
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();
        double percent = _remainingSeconds / (_initialSeconds == 0 ? 1 : _initialSeconds);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: _isRunning ? theme.accentColor.withOpacity(0.05) : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

              const SizedBox(height: 100),
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
// 2. ALARM TAB (FIXED: Saves to Hive + Keeps State)
// =========================================================
class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> with AutomaticKeepAliveClientMixin {
  // ✅ Keeps alarm list visible when switching tabs
  @override
  bool get wantKeepAlive => true;

  late Box _alarmBox;
  List<Map<String, dynamic>> alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  // ✅ LOAD ALARMS FROM DATABASE
  Future<void> _loadAlarms() async {
    _alarmBox = await Hive.openBox('alarmsBox');
    if (_alarmBox.isNotEmpty) {
      setState(() {
        alarms = List<Map<String, dynamic>>.from(
            _alarmBox.values.map((e) {
              // Convert stored map back to usable format (TimeOfDay needs reconstruction)
              final map = Map<String, dynamic>.from(e);
              return {
                'id': map['id'],
                'hour': map['hour'],
                'minute': map['minute'],
                'label': map['label'],
                'isActive': map['isActive'],
              };
            })
        );
      });
    }
  }

  // ✅ SAVE ALARMS TO DATABASE
  Future<void> _saveAlarms() async {
    await _alarmBox.clear();
    for (var alarm in alarms) {
      await _alarmBox.add(alarm);
    }
  }

  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _toggleAlarm(int index, bool val) {
    setState(() => alarms[index]['isActive'] = val);
    final alarm = alarms[index];

    if (val) {
      final DateTime scheduledTime = _nextInstanceOfTime(alarm['hour'], alarm['minute']);
      NotificationService.scheduleAlarm(
          id: alarm['id'],
          title: alarm['label'],
          time: scheduledTime
      );
    } else {
      NotificationService.cancelNotification(alarm['id']);
    }
    _saveAlarms(); // ✅ Save change
  }

  void _addAlarm() async {
    final theme = ThemeManager();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
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
        alarms.add({
          'id': newId,
          'hour': picked.hour,
          'minute': picked.minute,
          'label': 'New Mission',
          'isActive': true
        });
      });

      final DateTime scheduledTime = _nextInstanceOfTime(picked.hour, picked.minute);
      NotificationService.scheduleAlarm(
          id: newId,
          title: "New Mission",
          time: scheduledTime
      );
      _saveAlarms(); // ✅ Save new alarm
    }
  }

  void _deleteAlarm(int index) {
    NotificationService.cancelNotification(alarms[index]['id']);
    setState(() {
      alarms.removeAt(index);
    });
    _saveAlarms(); // ✅ Save deletion
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Required for KeepAlive
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
              return Dismissible(
                key: Key(alarm['id'].toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteAlarm(index),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Container(
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
                              "${alarm['hour'].toString().padLeft(2,'0')}:${alarm['minute'].toString().padLeft(2,'0')}",
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
// 3. STOPWATCH TAB (Fixed: Keeps state alive)
// =========================================================
class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> with AutomaticKeepAliveClientMixin {
  // ✅ Keeps stopwatch running when switching tabs
  @override
  bool get wantKeepAlive => true;

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
    super.build(context); // ✅ Required for KeepAlive
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
                color: theme.textColor,
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
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}