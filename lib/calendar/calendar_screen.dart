import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ✅ Added for persistence
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

  // ✅ Hive Box for persistent storage
  late Box _calendarBox;

  // Data Source for Calendar
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initData();
  }

  // --- 1. INITIALIZE & LOAD DATA ---
  Future<void> _initData() async {
    // Open Box
    _calendarBox = await Hive.openBox('calendar_events');

    // Ensure Notifications are ready
    NotificationService.init();

    _loadEvents();
  }

  // --- 2. LOAD EVENTS FROM HIVE ---
  void _loadEvents() {
    final rawData = _calendarBox.get('events', defaultValue: []);
    final List<dynamic> storedEvents = List<dynamic>.from(rawData);

    Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};

    for (var item in storedEvents) {
      final event = Map<String, dynamic>.from(item);
      final DateTime date = DateTime.parse(event['date']); // Rehydrate Date
      final DateTime utcDate = DateTime.utc(date.year, date.month, date.day);

      if (tempEvents[utcDate] == null) tempEvents[utcDate] = [];
      tempEvents[utcDate]!.add(event);
    }

    setState(() {
      _events = tempEvents;
    });
  }

  // --- 3. SAVE EVENTS TO HIVE ---
  Future<void> _saveEvents() async {
    // Flatten Map back to List for Hive storage
    List<Map<String, dynamic>> allEvents = [];
    _events.forEach((key, value) {
      allEvents.addAll(value);
    });
    await _calendarBox.put('events', allEvents);
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  // --- 4. ADD NEW OPERATION ---
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

      // ✅ LOGIC: Expected = User Date, Actual = TBD
      final newEvent = {
        'id': DateTime.now().millisecondsSinceEpoch, // Unique ID
        'type': 1,
        'title': title,
        'expected': DateFormat('MMM d, HH:mm').format(date),
        'actual': 'TBD',
        'isCompleted': false,
        'date': utcDate.toIso8601String(), // Store as string for Hive
      };

      setState(() {
        if (_events[utcDate] == null) _events[utcDate] = [];
        _events[utcDate]!.add(newEvent);
        _selectedDay = utcDate;
        _focusedDay = utcDate;
      });

      _saveEvents(); // Save to disk

      await NotificationService.scheduleDeadlineNotification(
        id: date.hashCode,
        title: title,
        date: date,
      );
    }
  }

  // --- 5. COMPLETE OPERATION (CHECKLIST) ---
  void _toggleOperationComplete(Map<String, dynamic> event) {
    setState(() {
      // Toggle Status
      event['isCompleted'] = !event['isCompleted'];

      // ✅ LOGIC: If complete, set Actual to NOW. If unchecked, reset to TBD.
      if (event['isCompleted']) {
        event['actual'] = DateFormat('MMM d, HH:mm').format(DateTime.now());
      } else {
        event['actual'] = 'TBD';
      }
    });

    _saveEvents(); // Save changes immediately
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, theme, child) {
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

          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 30),

                // --- HEADER ---
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

                const SizedBox(height: 20),

                // --- CALENDAR ---
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

                // --- MISSION LOG HEADER ---
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

                // --- EVENT LIST ---
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
                          // Fallback for older events or different types
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildBirthdayCard(theme, event['title'] ?? "Event", accentGold),
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
    bool isCompleted = event['isCompleted'] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCompleted
                ? Colors.green.withOpacity(0.5)
                : theme.textColor.withOpacity(0.05)
        ),
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
                    decoration: BoxDecoration(
                        color: isCompleted ? Colors.green.withOpacity(0.1) : color.withOpacity(0.1),
                        shape: BoxShape.circle
                    ),
                    child: Icon(
                        isCompleted ? Icons.check_circle : Icons.timer_outlined,
                        color: isCompleted ? Colors.green : color,
                        size: 16
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: TextStyle(
                            color: theme.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCompleted ? "Operation Complete" : "Pending Execution",
                        style: TextStyle(
                            color: isCompleted ? Colors.green : color,
                            fontSize: 9,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // ✅ CHECKLIST BUTTON
              Checkbox(
                value: isCompleted,
                activeColor: Colors.green,
                side: BorderSide(color: theme.subText, width: 2),
                onChanged: (val) => _toggleOperationComplete(event),
              )
            ],
          ),
          const SizedBox(height: 12),
          // ✅ ANALYSIS ROW
          Row(
            children: [
              Expanded(child: _buildStatColumn(theme, "EXPECTED", event['expected'], theme.textColor)),
              Container(width: 1, height: 24, color: theme.subText.withOpacity(0.2)),
              Expanded(child: _buildStatColumn(
                  theme,
                  "ACTUAL",
                  event['actual'],
                  isCompleted ? Colors.green : color
              )),
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
            child: Icon(Icons.star, color: color, size: 20),
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
                "Special Event",
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
          style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}