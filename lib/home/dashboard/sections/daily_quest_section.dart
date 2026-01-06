import 'package:flutter/material.dart';

class DailyQuestSection extends StatelessWidget {
  // Accept the list of quests dynamically
  final List<Map<String, dynamic>> quests;

  const DailyQuestSection({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("ACTIVE QUESTS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("See All", style: TextStyle(color: const Color(0xFF6C63FF).withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),

        // BUILD LIST DYNAMICALLY
        ...quests.map((quest) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildTaskTile(
                quest['title'],
                quest['subtitle'],
                quest['isCompleted'],
                quest['xp']
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTaskTile(String title, String subtitle, bool isCompleted, int xp) {
    // Determine Color based on subtitle content (Simple logic)
    Color accent = const Color(0xFF54A0FF); // Default Blue
    if (subtitle.contains("Fitness") || subtitle.contains("Strength")) accent = const Color(0xFFFF9F43);
    if (subtitle.contains("Study") || subtitle.contains("Intellect")) accent = const Color(0xFF00BFA6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCompleted ? accent.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isCompleted ? Icons.check : Icons.circle_outlined, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, decoration: isCompleted ? TextDecoration.lineThrough : null, decorationColor: Colors.grey)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
          Text("+$xp XP", style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}