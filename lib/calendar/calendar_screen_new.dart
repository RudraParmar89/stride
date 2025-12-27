import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/xp_controller.dart';
import '../controllers/task_controller.dart';
import '../selection/mode_controller.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // Student Mode Data
  Map<String, String> _dailyStatus = {}; // Date -> status (completed/partial/missed)
  Map<String, List<Map<String, dynamic>>> _plannedTasks = {}; // Date -> list of planned tasks
  Map<String, List<Map<String, dynamic>>> _completedTasks = {}; // Date -> list of completed tasks

  // Student-specific events
  List<Map<String, dynamic>> _studentEvents = [];

  // XP and Streak data
  int _currentXP = 1250;
  int _currentStreak = 7;
  int _longestStreak = 14;

  // Shared preferences instance
  late SharedPreferences _prefs;

  // Events list (for compatibility)
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
    _initializeStudentData();
  }

  Future<void> _loadCalendarData() async {
    _prefs = await SharedPreferences.getInstance();
    final dailyStatus = _prefs.getStringList('daily_status') ?? [];
    final plannedTasks = _prefs.getStringList('planned_tasks') ?? [];
    final completedTasks = _prefs.getStringList('completed_tasks') ?? [];

    setState(() {
      // Load daily status
      for (final status in dailyStatus) {
        final parts = status.split('|');
        if (parts.length == 2) {
          _dailyStatus[parts[0]] = parts[1];
        }
      }

      // Load planned tasks
      for (final task in plannedTasks) {
        final parts = task.split('|');
        if (parts.length >= 3) {
          final date = parts[0];
          final taskData = {
            'title': parts[1],
            'type': parts[2],
            'completed': parts.length > 3 ? parts[3] == 'true' : false,
          };
          _plannedTasks[date] ??= [];
          _plannedTasks[date]!.add(taskData);
        }
      }

      // Load completed tasks
      for (final task in completedTasks) {
        final parts = task.split('|');
        if (parts.length >= 3) {
          final date = parts[0];
          final taskData = {
            'title': parts[1],
            'type': parts[2],
            'time': parts.length > 3 ? parts[3] : null,
          };
          _completedTasks[date] ??= [];
          _completedTasks[date]!.add(taskData);
        }
      }
    });
  }

  void _initializeStudentData() {
    // Initialize with sample student data
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    _studentEvents = [
      {
        'date': today,
        'title': 'Math Exam - Calculus',
        'type': 'exam',
        'time': '10:00 AM',
        'priority': 'high',
        'xp': 50,
      },
      {
        'date': tomorrow,
        'title': 'Physics Assignment Due',
        'type': 'assignment',
        'time': '11:59 PM',
        'priority': 'high',
        'xp': 30,
      },
      {
        'date': today.add(const Duration(days: 2)),
        'title': 'Study Block - Chemistry',
        'type': 'study',
        'time': '2:00 PM',
        'priority': 'medium',
        'xp': 25,
      },
      {
        'date': today.add(const Duration(days: 5)),
        'title': 'Computer Science Project',
        'type': 'project',
        'time': 'All Day',
        'priority': 'high',
        'xp': 75,
      },
    ];

    // Set some sample daily statuses
    _dailyStatus = {
      DateFormat('yyyy-MM-dd').format(yesterday): 'completed',
      DateFormat('yyyy-MM-dd').format(yesterday.subtract(const Duration(days: 1))): 'completed',
      DateFormat('yyyy-MM-dd').format(yesterday.subtract(const Duration(days: 2))): 'partial',
      DateFormat('yyyy-MM-dd').format(yesterday.subtract(const Duration(days: 3))): 'missed',
    };

    // Sample planned vs completed tasks
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    _plannedTasks[todayKey] = [
      {'title': 'Math Study Session', 'type': 'study', 'completed': true},
      {'title': 'Physics Lab Report', 'type': 'assignment', 'completed': true},
      {'title': 'Chemistry Reading', 'type': 'study', 'completed': false},
      {'title': 'CS Coding Practice', 'type': 'practice', 'completed': true},
    ];

    _completedTasks[todayKey] = [
      {'title': 'Math Study Session', 'type': 'study', 'time': '9:00 AM'},
      {'title': 'Physics Lab Report', 'type': 'assignment', 'time': '11:00 AM'},
      {'title': 'CS Coding Practice', 'type': 'practice', 'time': '3:00 PM'},
    ];
  }

  String _getDailyStatus(String dateKey) {
    return _dailyStatus[dateKey] ?? 'none';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF2ECC71); // Green
      case 'partial':
        return const Color(0xFFF39C12); // Orange
      case 'missed':
        return const Color(0xFFE74C3C); // Red
      default:
        return Colors.white.withOpacity(0.1);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'partial':
        return Icons.warning;
      case 'missed':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case 'completed':
        return '✅';
      case 'partial':
        return '⚠️';
      case 'missed':
        return '❌';
      default:
        return '○';
    }
  }

  Widget _buildXPStreakHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('XP', _currentXP.toString(), Icons.star, const Color(0xFFF39C12)),
          _buildStatItem('Streak', '${_currentStreak}d', Icons.local_fire_department, const Color(0xFFE74C3C)),
          _buildStatItem('Best', '${_longestStreak}d', Icons.emoji_events, const Color(0xFF2ECC71)),
        ],
      ),
    );
  }
