import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/theme_manager.dart';

class HunterBentoSection extends StatefulWidget {
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
  State<HunterBentoSection> createState() => _HunterBentoSectionState();
}

class _HunterBentoSectionState extends State<HunterBentoSection> {
  double waterAmount = 1.2;
  double sleepHours = 7.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, theme, child) {

        double taskProgress =
            widget.totalTasks > 0 ? (widget.completedTasks / widget.totalTasks) : 0.0;
        String taskString = "${widget.completedTasks}/${widget.totalTasks}";

        return Column(
          children: [
            // ROW 1
            Row(
              children: [
                Expanded(
                  child: _buildCompactCard(
                    theme,
                    title: "STRENGTH",
                    value: _formatSteps(widget.steps),
                    unit: "Steps",
                    icon: Icons.directions_walk_rounded,
                    color: const Color(0xFFFF5252),
                    progress: (widget.steps / 10000).clamp(0.0, 1.0),
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
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        waterAmount += details.delta.dy * -0.01;
                        waterAmount = waterAmount.clamp(0.0, 10.0);
                      });
                    },
                    child: _buildMiniCard(
                      theme,
                      value: "${waterAmount.toStringAsFixed(1)}L",
                      unit: "Water",
                      icon: Icons.water_drop_rounded,
                      color: const Color(0xFF00D2D3),
                    ),
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
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        sleepHours += (details.delta.dy * -0.1).round() * 0.5;
                        sleepHours = sleepHours.clamp(0.0, 13.0);
                      });
                    },
                    child: _buildMiniCard(
                      theme,
                      value: "${sleepHours.toStringAsFixed(1)}h",
                      unit: "Sleep",
                      icon: Icons.bedtime_rounded,
                      color: const Color(0xFFE056FD),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // CHATBOT OPINION
            Text(
              _getChatbotOpinion(),
              style: TextStyle(
                color: theme.subText,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  String _getChatbotOpinion() {
    String waterMsg = "";
    if (waterAmount < 2.0) {
      waterMsg = "Drink more water to stay hydrated!";
    } else if (waterAmount < 3.0) {
      waterMsg = "Good start on water intake!";
    } else {
      waterMsg = "Excellent hydration!";
    }

    String sleepMsg = "";
    if (sleepHours < 6.0) {
      sleepMsg = "Get more sleep tonight!";
    } else if (sleepHours < 8.0) {
      sleepMsg = "Decent sleep, aim for more!";
    } else {
      sleepMsg = "Great sleep habits!";
    }

    return "$waterMsg $sleepMsg";
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
