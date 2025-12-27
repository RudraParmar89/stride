import 'package:flutter/material.dart';

class DashboardActionGrid extends StatelessWidget {
  final VoidCallback onNewHabit;

  const DashboardActionGrid({
    super.key,
    required this.onNewHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _action(Icons.add, "New Habit", onTap: onNewHabit),
        _action(Icons.calendar_month_outlined, "Calendar"),
        _action(Icons.school_outlined, "Study"),
        _action(Icons.more_horiz, "More"),
      ],
    );
  }

  Widget _action(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
