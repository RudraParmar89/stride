import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Services & Modals
import '../services/notification_service.dart';
import 'modals/add_project_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock Data: 1 = Deadline, 2 = Birthday
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.utc(2025, 1, 15): [{'type': 1, 'title': 'Flutter Prototype', 'expected': '4h', 'actual': '5.5h'}],
    DateTime.utc(2025, 1, 20): [{'type': 2, 'title': "Astra's Creation Day"}],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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

        // Jump to the new date immediately
        _selectedDay = utcDate;
        _focusedDay = utcDate;
      });

      await NotificationService.scheduleDeadlineNotification(
        id: date.hashCode,
        title: title,
        deadline: date,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Operation '$title' tracked. Notification set."),
          backgroundColor: const Color(0xFF1E1E2C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF1E1E2C);
    const Color primary = Color(0xFF6C63FF);
    const Color accentRed = Color(0xFFFF5252);
    const Color accentGold = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B15),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: _openAddProjectSheet,
          backgroundColor: accentRed,
          icon: const Icon(Icons.add_task, color: Colors.white),
          label: const Text("NEW OP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "OPERATION TIMELINE",
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. CALENDAR (WIDER & BIGGER)
          Container(
            // Reduced margin from 24 to 12 to make it wider
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              rowHeight: 52, // Slightly taller rows for better touch targets
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getEventsForDay,

              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white), rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white)),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                weekendTextStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 14),
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: primary, width: 2)),
                todayTextStyle: const TextStyle(color: primary, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(color: primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primary.withOpacity(0.5), blurRadius: 12)]),
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.map((e) {
                      final data = e as Map<String, dynamic>;
                      Color color = (data['type'] == 1) ? accentRed : accentGold;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 5, height: 5,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)]),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. MISSION LOG HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(width: 3, height: 14, color: primary),
                const SizedBox(width: 8),
                Text("MISSION LOG: ${DateFormat('MMM d').format(_selectedDay ?? DateTime.now()).toUpperCase()}", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              ],
            ),
          ),

          const SizedBox(height: 12), // Reduced gap

          // 3. EVENT LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                ..._getEventsForDay(_selectedDay ?? DateTime.now()).map((event) {
                  if (event['type'] == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0), // Reduced spacing
                      child: _buildDeadlineCard(
                        title: event['title'],
                        expected: event['expected'],
                        actual: event['actual'],
                        color: accentRed,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0), // Reduced spacing
                      child: _buildBirthdayCard(name: event['title'], color: accentGold),
                    );
                  }
                }),

                if (_getEventsForDay(_selectedDay ?? DateTime.now()).isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text("NO OPERATIONS SCHEDULED", style: TextStyle(color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SLIMMER DEADLINE CARD ---
  Widget _buildDeadlineCard({required String title, required String expected, required String actual, required Color color}) {
    return Container(
      // REDUCED PADDING: 16 horizontal, 12 vertical (Slimmer)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.timer_off_outlined, color: color, size: 16)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text("Critical Deadline", style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold))]),
          ]),
        ]),
        const SizedBox(height: 12), // Reduced gap
        Row(children: [
          Expanded(child: _buildStatColumn("EXPECTED", expected, Colors.white)),
          Container(width: 1, height: 24, color: Colors.white10),
          Expanded(child: _buildStatColumn("ACTUAL", actual, color)),
        ]),
      ]),
    );
  }

  // --- SLIMMER BIRTHDAY CARD ---
  Widget _buildBirthdayCard({required String name, required Color color}) {
    return Container(
      // REDUCED PADDING (Slimmer)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.cake_rounded, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), Text("Guild Member Anniversary", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11))]),
      ]),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(children: [Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)), const SizedBox(height: 2), Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold))]);
  }
}