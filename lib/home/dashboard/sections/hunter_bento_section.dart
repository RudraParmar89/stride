import 'package:flutter/material.dart';

class HunterBentoSection extends StatelessWidget {
  const HunterBentoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ROW 1: Two Wide Cards (Detailed)
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                context,
                title: "STRENGTH",
                value: "8,432",
                unit: "Steps",
                icon: Icons.directions_walk_rounded,
                color: const Color(0xFFFF5252), // Red
                progress: 0.8,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                context,
                title: "INTELLECT",
                value: "4h 12m",
                unit: "Focus",
                icon: Icons.psychology_rounded,
                color: const Color(0xFF6C63FF), // Purple
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
  }

  // WIDE CARD (Top Row)
  Widget _buildCompactCard(BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      height: 90, // Reduced height for sleek look
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2)),
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
                      color: Colors.white.withOpacity(0.5),
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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
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
                  backgroundColor: Colors.white.withOpacity(0.05),
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
  Widget _buildMiniCard(BuildContext context, {
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 90, // Same height as top row for alignment
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2)),
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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
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