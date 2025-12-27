import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // -------------------- CORE --------------------
  late SharedPreferences _prefs;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // -------------------- STUDENT DATA --------------------
  /// yyyy-MM-dd -> completed / partial / missed
  final Map<String, String> _dailyStatus = {};

  /// Academic events
  final List<Map<String, dynamic>> _studentEvents = [];

  /// Planned tasks per day
  final Map<String, List<Map<String, dynamic>>> _plannedTasks = {};

  /// Completed tasks per day
  final Map<String, List<Map<String, dynamic>>> _completedTasks = {};

  // -------------------- XP & STREAK --------------------
  int _currentXP = 1250;
  int _currentStreak = 7;
  int _longestStreak = 14;

  // -------------------- INIT --------------------
  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPersistedData();
    _seedStudentData(); // demo data
    setState(() {});
  }

  // -------------------- STORAGE --------------------
  void _loadPersistedData() {
    final savedStatus = _prefs.getStringList('daily_status') ?? [];

    for (final entry in savedStatus) {
      final parts = entry.split('|');
      if (parts.length == 2) {
        _dailyStatus[parts[0]] = parts[1];
      }
    }
  }

  // -------------------- DEMO DATA --------------------
  void _seedStudentData() {
    final today = DateTime.now();

    _studentEvents.addAll([
      {
        'date': today,
        'title': 'Math Exam - Calculus',
        'type': 'exam',
        'time': '10:00 AM',
        'priority': 'high',
        'completed': true,
        'xp': 50,
      },
      {
        'date': today.add(const Duration(days: 1)),
        'title': 'Physics Assignment Due',
        'type': 'assignment',
        'time': '11:59 PM',
        'priority': 'high',
        'completed': false,
        'xp': 30,
      },
      {
        'date': today.add(const Duration(days: 3)),
        'title': 'Chemistry Study Block',
        'type': 'study',
        'time': '2:00 PM',
        'priority': 'medium',
        'completed': false,
        'xp': 20,
      },
      {
        'date': today.add(const Duration(days: 5)),
        'title': 'CS Project Submission',
        'type': 'project',
        'time': 'All Day',
        'priority': 'high',
        'completed': false,
        'xp': 80,
      },
    ]);

    _dailyStatus.addAll({
      _dateKey(today.subtract(const Duration(days: 1))): 'completed',
      _dateKey(today.subtract(const Duration(days: 2))): 'completed',
      _dateKey(today.subtract(const Duration(days: 3))): 'partial',
      _dateKey(today.subtract(const Duration(days: 4))): 'missed',
    });

    final todayKey = _dateKey(today);

    _plannedTasks[todayKey] = [
      {'title': 'Math Revision', 'type': 'study', 'completed': true},
      {'title': 'Physics Notes', 'type': 'study', 'completed': false},
      {'title': 'DSA Practice', 'type': 'practice', 'completed': true},
    ];

    _completedTasks[todayKey] = [
      {'title': 'Math Revision', 'type': 'study', 'time': '9:00 AM'},
      {'title': 'DSA Practice', 'type': 'practice', 'time': '4:00 PM'},
    ];
  }

  // -------------------- HELPERS --------------------
  String _dateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  String _getDayStatus(DateTime date) {
    if (date.isAfter(DateTime.now())) return 'planned';
    return _dailyStatus[_dateKey(date)] ?? 'missed';
  }

  List<Map<String, dynamic>> _eventsForDate(DateTime date) {
    return _studentEvents.where((event) {
      final d = event['date'] as DateTime;
      return d.year == date.year &&
          d.month == date.month &&
          d.day == date.day;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF2ECC71);
      case 'partial':
        return const Color(0xFFF39C12);
      case 'missed':
        return const Color(0xFFE74C3C);
      default:
        return Colors.transparent;
    }
  }

  String _statusEmoji(String status) {
    switch (status) {
      case 'completed':
        return '✅';
      case 'partial':
        return '⚠️';
      case 'missed':
        return '❌';
      default:
        return '📅';
    }
  }
  // =========================================================
  // UI BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3D2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Academic Calendar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showWeeklyReview,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildXPStreakHeader(),
            const SizedBox(height: 16),
            _buildCalendarContainer(),
            const SizedBox(height: 16),
            _buildSelectedDateDetails(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // XP + STREAK HEADER
  // =========================================================

  Widget _buildXPStreakHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('XP', _currentXP.toString(), Icons.star, Colors.amber),
          _statItem(
              'Streak', '${_currentStreak}d', Icons.local_fire_department, Colors.red),
          _statItem(
              'Best', '${_longestStreak}d', Icons.emoji_events, Colors.green),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CALENDAR CONTAINER
  // =========================================================

  Widget _buildCalendarContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildWeekHeader(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  // =========================================================
  // CALENDAR GRID (FULL LOGIC)
  // =========================================================

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
    DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth =
    DateTime(_focusedDate.year, _focusedDate.month + 1, 0);

    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final List<DateTime> days = [];

    // Previous month fillers
    final prevMonth =
    DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
    final prevMonthLastDay =
        DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(DateTime(
          prevMonth.year, prevMonth.month, prevMonthLastDay - i));
    }

    // Current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedDate.year, _focusedDate.month, i));
    }

    // Next month fillers
    while (days.length < 42) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final date = days[index];
        final isCurrentMonth = date.month == _focusedDate.month;
        final isSelected = _dateKey(date) == _dateKey(_selectedDate);
        final isToday = _dateKey(date) == _dateKey(DateTime.now());
        final status = _getDayStatus(date);
        final hasEvents = _eventsForDate(date).isNotEmpty;

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.35)
                  : isToday
                  ? Colors.green.withOpacity(0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: hasEvents && !isSelected
                  ? Border.all(
                  color: Colors.orange.withOpacity(0.6), width: 2)
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isCurrentMonth
                          ? Colors.white
                          : Colors.white38,
                      fontWeight:
                      isSelected || isToday ? FontWeight.bold : null,
                    ),
                  ),
                ),
                if (isCurrentMonth && status != 'planned')
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _statusEmoji(status),
                          style: const TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  // =========================================================
  // SELECTED DATE DETAILS
  // =========================================================

  Widget _buildSelectedDateDetails() {
    final status = _getDayStatus(_selectedDate);
    final events = _eventsForDate(_selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(_selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 16),

          if (events.isNotEmpty) ...[
            const Text(
              'Academic Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...events.map(_buildStudentEventItem),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No academic events scheduled',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor(status), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_statusEmoji(status), style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _statusColor(status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STUDENT EVENT ITEM
  // =========================================================

  Widget _buildStudentEventItem(Map<String, dynamic> event) {
    Color color;
    IconData icon;
    String priorityEmoji;

    switch (event['type']) {
      case 'exam':
        color = Colors.red;
        icon = Icons.school;
        break;
      case 'assignment':
        color = Colors.blue;
        icon = Icons.assignment;
        break;
      case 'project':
        color = Colors.purple;
        icon = Icons.work;
        break;
      case 'study':
        color = Colors.green;
        icon = Icons.book;
        break;
      default:
        color = Colors.grey;
        icon = Icons.event;
    }

    switch (event['priority']) {
      case 'high':
        priorityEmoji = '🔴';
        break;
      case 'medium':
        priorityEmoji = '🟡';
        break;
      case 'low':
        priorityEmoji = '🟢';
        break;
      default:
        priorityEmoji = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (priorityEmoji.isNotEmpty)
                      Text(priorityEmoji, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if (event['time'] != null)
                  Text(
                    event['time'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (event['completed'] == true)
            const Icon(Icons.check_circle, color: Colors.green),
          if (event['xp'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                '+${event['xp']} XP',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // UPCOMING EVENTS
  // =========================================================

  Widget _buildUpcomingEvents() {
    final upcoming = _getUpcomingStudentEvents();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Academic Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (upcoming.isNotEmpty)
            ...upcoming.take(5).map(_buildUpcomingEventItem)
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No upcoming events',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventItem(Map<String, dynamic> event) {
    final daysUntil =
        (event['date'] as DateTime).difference(DateTime.now()).inDays;

    final label = daysUntil == 0
        ? 'Today'
        : daysUntil == 1
        ? 'Tomorrow'
        : 'In $daysUntil days';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: _eventTypeColor(event['type']),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$label • ${event['time'] ?? ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(_eventTypeEmoji(event['type']),
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Color _eventTypeColor(String type) {
    switch (type) {
      case 'exam':
        return Colors.red;
      case 'assignment':
        return Colors.blue;
      case 'project':
        return Colors.purple;
      case 'study':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _eventTypeEmoji(String type) {
    switch (type) {
      case 'exam':
        return '📝';
      case 'assignment':
        return '📄';
      case 'project':
        return '🚀';
      case 'study':
        return '📚';
      default:
        return '📅';
    }
  }

  List<Map<String, dynamic>> _getUpcomingStudentEvents() {
    final now = DateTime.now();
    return _studentEvents
        .where((e) =>
    (e['date'] as DateTime).isAfter(now) ||
        _dateKey(e['date']) == _dateKey(now))
        .toList()
      ..sort((a, b) =>
          (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }
  // =========================================================
  // WEEKLY REVIEW (BOTTOM SHEET)
  // =========================================================

  void _showWeeklyReview() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF0F3D2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            _buildWeeklyHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildWeeklyStats(),
                    const SizedBox(height: 28),
                    _buildPlanningVsReality(),
                    const SizedBox(height: 28),
                    _buildWeeklyInsights(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Weekly Review',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WEEKLY STATS
  // =========================================================

  Widget _buildWeeklyStats() {
    final stats = _calculateWeeklyStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weeklyStatItem('Completed', '${stats['completed']}', '✅'),
              _weeklyStatItem('Partial', '${stats['partial']}', '⚠️'),
              _weeklyStatItem('Missed', '${stats['missed']}', '❌'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weeklyStatItem('XP Earned', '${stats['xpEarned']}', '⭐'),
              _weeklyStatItem('Streak', '${stats['currentStreak']}d', '🔥'),
              _weeklyStatItem('Events', '${stats['eventsCompleted']}', '📚'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weeklyStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PLANNING VS REALITY
  // =========================================================

  Widget _buildPlanningVsReality() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Planning vs Reality',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'This compares what you planned with what you actually completed.\n\n'
                '• Green = fully completed days\n'
                '• Orange = partially completed days\n'
                '• Red = missed days\n\n'
                'Detailed analytics coming soon.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WEEKLY INSIGHTS
  // =========================================================

  Widget _buildWeeklyInsights() {
    final insights = _generateWeeklyInsights();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Insights',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...insights.map(
                (text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WEEKLY CALCULATIONS
  // =========================================================

  Map<String, dynamic> _calculateWeeklyStats() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    int completed = 0;
    int partial = 0;
    int missed = 0;
    int xpEarned = 0;
    int eventsCompleted = 0;

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final status = _getDayStatus(date);

      switch (status) {
        case 'completed':
          completed++;
          break;
        case 'partial':
          partial++;
          break;
        case 'missed':
          missed++;
          break;
      }

      for (final event in _eventsForDate(date)) {
        if (event['completed'] == true) {
          eventsCompleted++;
          xpEarned += (event['xp'] as int?) ?? 0;

        }
      }
    }

    return {
      'completed': completed,
      'partial': partial,
      'missed': missed,
      'xpEarned': xpEarned,
      'eventsCompleted': eventsCompleted,
      'currentStreak': _currentStreak,
    };
  }

  List<String> _generateWeeklyInsights() {
    final stats = _calculateWeeklyStats();
    final List<String> insights = [];

    if (stats['completed'] >= 5) {
      insights.add(
          'Excellent discipline! You completed ${stats['completed']} days this week.');
    } else if (stats['completed'] >= 3) {
      insights.add(
          'Good progress. Try pushing for more consistent full days.');
    } else {
      insights.add(
          'This week was tough. Focus on smaller, achievable goals next week.');
    }

    if (_currentStreak >= 7) {
      insights.add(
          '🔥 Strong streak! Maintaining ${_currentStreak} days shows real consistency.');
    }

    if (stats['xpEarned'] >= 100) {
      insights.add(
          '⭐ You earned ${stats['xpEarned']} XP this week. Momentum is building.');
    }

    if (insights.isEmpty) {
      insights.add(
          'Start tracking your tasks daily to unlock personalized insights.');
    }

    return insights;
  }
}
