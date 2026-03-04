import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago; // Optional: Add 'timeago' to pubspec.yaml for "5m ago" text

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Notifications
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Level Up!",
        "message": "You reached Level 13. New abilities unlocked.",
        "type": "levelup",
        "time": DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        "title": "Quest Complete",
        "message": "Tactical Briefing completed. +25 XP earned.",
        "type": "success",
        "time": DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        "title": "Streak Warning",
        "message": "You haven't logged your water intake today.",
        "type": "warning",
        "time": DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        "title": "New Protocol",
        "message": "Weekly Horizon section is now available.",
        "type": "info",
        "time": DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white, // Or ThemeManager().bgColor
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SYSTEM LOGS",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blueAccent),
            onPressed: () {}, // Logic to clear all
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _NotificationCard(
            title: item['title'],
            message: item['message'],
            type: item['type'],
            time: item['time'],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String type;
  final DateTime time;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.type,
    required this.time,
  });

  Color _getColor() {
    switch (type) {
      case 'levelup': return Colors.purpleAccent;
      case 'success': return Colors.green;
      case 'warning': return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case 'levelup': return Icons.keyboard_double_arrow_up;
      case 'success': return Icons.check_circle_outline;
      case 'warning': return Icons.warning_amber_rounded;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(), color: color, size: 20),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "${time.hour}:${time.minute.toString().padLeft(2, '0')}", // Simple time format
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}