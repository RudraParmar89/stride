import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart';

class HunterBentoSection extends StatelessWidget {
  final int steps;
  final int completedTasks;
  final int totalTasks;

  const HunterBentoSection({
    super.key,
    this.steps = 0,
    this.completedTasks = 0,
    this.totalTasks = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        double taskProgress =
            totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
        String taskString = "$completedTasks/$totalTasks";

        return Column(
          children: [
            // ROW 1
            Row(
              children: [
                Expanded(
                  child: _buildCompactCard(
                    theme,
                    title: "STRENGTH",
                    value: _formatSteps(steps),
                    unit: "Steps",
                    icon: Icons.directions_walk_rounded,
                    color: const Color(0xFFFF5252),
                    progress: (steps / 10000).clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCompactCard(
                    theme,
                    title: "INTELLECT",
                    value: taskString,
                    unit: "Missions",
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF6C63FF),
                    progress: taskProgress,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ROW 2
            Row(
              children: [
                Expanded(
                  child: _buildMiniCard(
                    theme,
                    value: "1.2L",
                    unit: "Water",
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF00D2D3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniCard(
                    theme,
                    value: taskString,
                    unit: "Tasks",
                    icon: Icons.list_alt_rounded,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniCard(
                    theme,
                    value: "7h",
                    unit: "Sleep",
                    icon: Icons.bedtime_rounded,
                    color: const Color(0xFFE056FD),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatSteps(int steps) {
    if (steps > 1000) {
      return "${(steps / 1000).toStringAsFixed(1)}k";
    }
    return steps.toString();
  }

  // WIDE CARD
  Widget _buildCompactCard(
    ThemeManager theme, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.textColor.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.subText,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  color: theme.subText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: theme.subText.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // MINI CARD (FIXED OVERFLOW)
  Widget _buildMiniCard(
  ThemeManager theme, {
  required String value,
  required String unit,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.textColor.withOpacity(0.05)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // ✅ KEY FIX
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.subText,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

}
