// Place this in the same file or a new file: lib/home/dashboard/widgets/quest_tile.dart
import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart';

class QuestTile extends StatefulWidget {
  final Map<String, dynamic> quest;
  final VoidCallback onTap;
  final int index; // For staggered animation delay

  const QuestTile({
    super.key,
    required this.quest,
    required this.onTap,
    required this.index,
  });

  @override
  State<QuestTile> createState() => _QuestTileState();
}

class _QuestTileState extends State<QuestTile> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  void _handleTap() async {
    // 1. Shrink Effect (Press Down)
    await _scaleController.reverse();
    // 2. Expand Effect (Bounce Back)
    await _scaleController.forward();
    // 3. Trigger Logic
    widget.onTap();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = widget.quest['isCompleted'];
    String subtitle = widget.quest['subtitle'];

    // Determine Accent Color
    Color accent = const Color(0xFF54A0FF);
    if (subtitle.contains("Fitness")) accent = const Color(0xFFFF9F43);
    if (subtitle.contains("Study")) accent = const Color(0xFF00BFA6);

    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        final theme = ThemeManager();

        // STAGGERED ENTRANCE ANIMATION
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)), // Slide Up
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: _handleTap,
            child: ScaleTransition(
              scale: _scaleController,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  // Dynamic Background: Slightly lighter/colored when active
                  color: isCompleted
                      ? accent.withOpacity(0.15)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCompleted
                        ? accent.withOpacity(0.6)
                        : theme.textColor.withOpacity(0.05),
                    width: isCompleted ? 1.5 : 1,
                  ),
                  boxShadow: isCompleted
                      ? [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Row(
                  children: [
                    // ANIMATED CHECKBOX
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCompleted ? accent : accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20, key: ValueKey('done'))
                            : Icon(Icons.circle_outlined, color: accent, size: 20, key: const ValueKey('todo')),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // TEXT CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: isCompleted ? theme.subText : theme.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              decorationColor: accent,
                            ),
                            child: Text(widget.quest['title']),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(color: theme.subText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // XP BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "+${widget.quest['xp']} XP",
                        style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}