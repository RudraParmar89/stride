import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart'; // <--- IMPORT THEME MANAGER

class HunterBentoSection extends StatelessWidget {
  // 1. ACCEPT STEPS VARIABLE
  final int steps;

  const HunterBentoSection({
    super.key,
    this.steps = 0, // Default to 0 if not provided
  });

  @override
  Widget build(BuildContext context) {
    // 1. LISTEN TO THEME
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Column(
          children: [
            // ROW 1: Two Wide Cards (Detailed)
            Row(
              children: [
                Expanded(
                  child: _buildCompactCard(
                    context,
                    theme, // Pass Theme
                    title: "STRENGTH",
                    value: _formatSteps(steps), // <--- USE REAL STEPS HERE
                    unit: "Steps",
                    icon: Icons.directions_walk_rounded,
                    color: const Color(0xFFFF5252), // Red (Specific to Strength)
                    progress: (steps / 10000).clamp(0.0, 1.0), // <--- DYNAMIC PROGRESS (Goal: 10k)
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCompactCard(
                    context,
                    theme, // Pass Theme
                    title: "INTELLECT",
                    value: "4h 12m",
                    unit: "Focus",
                    icon: Icons.psychology_rounded,
                    color: const Color(0xFF6C63FF), // Purple (Specific to Intellect)
                    progress: 0.6,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10), // Tight spacing

            // ROW 2: Three Mini Cards (Quick Glance)
            Row(
              children: [
                Expanded(
                  child: _buildMiniCard(
                    context,
                    theme, // Pass Theme
                    value: "1.2L",
                    unit: "Water",
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF00D2D3), // Cyan
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniCard(
                    context,
                    theme, // Pass Theme
                    value: "5/8",
                    unit: "Tasks",
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFFFFD700), // Gold
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniCard(
                    context,
                    theme, // Pass Theme
                    value: "7h",
                    unit: "Sleep",
                    icon: Icons.bedtime_rounded,
                    color: const Color(0xFFE056FD), // Magenta
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Helper to format numbers (e.g., 1200 -> "1,200")
  String _formatSteps(int steps) {
    if (steps > 1000) {
      return "${(steps / 1000).toStringAsFixed(1)}k"; // 1.2k
    }
    return steps.toString();
  }

  // WIDE CARD (Top Row)
  Widget _buildCompactCard(BuildContext context, ThemeManager theme, {
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
        color: theme.cardColor, // <--- DYNAMIC BACKGROUND
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.textColor.withOpacity(0.05)),
        boxShadow: theme.isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.subText, // <--- DYNAMIC SUBTEXT
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
                    color: theme.textColor, // <--- DYNAMIC TEXT
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                    color: theme.subText, // <--- DYNAMIC SUBTEXT
                    fontSize: 10
                ),
              ),
            ],
          ),
          // Progress Circle
          SizedBox(
            width: 34,
            height: 34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: theme.subText.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                // Tiny dot in center
                Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MINI CARD (Bottom Row)
  Widget _buildMiniCard(BuildContext context, ThemeManager theme, {
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor, // <--- DYNAMIC BACKGROUND
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.textColor.withOpacity(0.05)),
        boxShadow: theme.isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                    color: theme.textColor, // <--- DYNAMIC TEXT
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                    color: theme.subText, // <--- DYNAMIC SUBTEXT
                    fontSize: 10
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}