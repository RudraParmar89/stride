import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/theme_manager.dart';

// Services
import '../services/notification_service.dart';

// Modals
import '../home/dashboard/modals/add_project_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock Data
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.utc(2025, 1, 15): [{'type': 1, 'title': 'Flutter Prototype', 'expected': '4h', 'actual': '5.5h'}],
    DateTime.utc(2025, 1, 20): [{'type': 2, 'title': "Astra's Creation Day"}],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Ensure notifications are initialized (safeguard)
    NotificationService.init();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _openAddProjectSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddProjectSheet(),
    );

    if (result != null) {
      final String title = result['title'];
      final DateTime date = result['date'];
      final DateTime utcDate = DateTime.utc(date.year, date.month, date.day);

      setState(() {
        if (_events[utcDate] == null) _events[utcDate] = [];
        _events[utcDate]!.add({
          'type': 1,
          'title': title,
          'expected': 'TBD',
          'actual': '0h',
        });
        _selectedDay = utcDate;
        _focusedDay = utcDate;
      });

      // FIX: Changed 'deadline' to 'date' to match NotificationService
      await NotificationService.scheduleDeadlineNotification(
        id: date.hashCode,
        title: title,
        date: date,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();
        const Color accentRed = Color(0xFFFF5252);
        const Color accentGold = Color(0xFFFFD700);

        return Scaffold(
          backgroundColor: theme.bgColor,

          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FloatingActionButton.extended(
              onPressed: _openAddProjectSheet,
              backgroundColor: accentRed,
              icon: const Icon(Icons.add_task, color: Colors.white),
              label: const Text("NEW OP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),

          // MOVED DOWN: Replaced AppBar with SafeArea + Column structure
          body: SafeArea(
            bottom: false, // Allow content to flow behind bottom nav
            child: Column(
              children: [
                // --- SPACER TO PUSH CONTENT DOWN ---
                const SizedBox(height: 30),

                // --- CUSTOM HEADER ---
                Center(
                  child: Text(
                    "OPERATION TIMELINE",
                    style: TextStyle(
                      color: theme.subText,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Spacing between header and calendar

                // 1. CALENDAR CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.textColor.withOpacity(0.05)),
                    boxShadow: theme.isDark
                        ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]
                        : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    rowHeight: 52,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: _getEventsForDay,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16),
                      leftChevronIcon: Icon(Icons.chevron_left, color: theme.subText),
                      rightChevronIcon: Icon(Icons.chevron_right, color: theme.subText),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14),
                      weekendTextStyle: TextStyle(color: theme.subText, fontWeight: FontWeight.bold, fontSize: 14),
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.accentColor, width: 2),
                      ),
                      todayTextStyle: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold),
                      selectedDecoration: BoxDecoration(
                        color: theme.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.4), blurRadius: 12)],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. MISSION LOG HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Container(width: 3, height: 14, color: theme.accentColor),
                      const SizedBox(width: 8),
                      Text(
                        "MISSION LOG: ${DateFormat('MMM d').format(_selectedDay ?? DateTime.now()).toUpperCase()}",
                        style: TextStyle(
                          color: theme.subText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. EVENT LIST
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      ..._getEventsForDay(_selectedDay ?? DateTime.now()).map((event) {
                        if (event['type'] == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildDeadlineCard(theme, event),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildBirthdayCard(theme, event['title'], accentGold),
                          );
                        }
                      }),
                      if (_getEventsForDay(_selectedDay ?? DateTime.now()).isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: Text(
                              "NO OPERATIONS SCHEDULED",
                              style: TextStyle(
                                color: theme.subText.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 120),
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

  // --- WIDGETS ---

  Widget _buildDeadlineCard(ThemeManager theme, Map<String, dynamic> event) {
    Color color = const Color(0xFFFF5252);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.textColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.timer_off_outlined, color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: TextStyle(color: theme.textColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Critical Deadline",
                        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatColumn(theme, "EXPECTED", event['expected'], theme.textColor)),
              Container(width: 1, height: 24, color: theme.subText.withOpacity(0.2)),
              Expanded(child: _buildStatColumn(theme, "ACTUAL", event['actual'], color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayCard(ThemeManager theme, String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.cake_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(color: theme.textColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                "Guild Member Anniversary",
                style: TextStyle(color: theme.subText, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(ThemeManager theme, String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.subText,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}