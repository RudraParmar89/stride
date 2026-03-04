import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../models/task.dart';

class QuestTile extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // ✅ Added

  const QuestTile({
    super.key,
    required this.task,
    required this.index,
    required this.onTap,
    this.onDelete, // ✅ Added to constructor
  });

  @override
  State<QuestTile> createState() => _QuestTileState();
}

class _QuestTileState extends State<QuestTile> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

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
    await _scaleController.reverse();
    await _scaleController.forward();
    widget.onTap();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength': return const Color(0xFFFF5252);      // Red
      case 'intellect': return const Color(0xFF6C63FF);     // Purple
      case 'vitality': return const Color(0xFF00D2D3);      // Cyan
      case 'spirit': return const Color(0xFFFFD700);        // Yellow/Gold
      case 'cardio': return const Color(0xFFFF7043);        // Orange
      case 'order': return const Color(0xFF4FC3F7);         // Light Blue
      case 'growth': return const Color(0xFF81C784);        // Green
      default: return const Color(0xFF9575CD);              // Light Purple for General
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getCategoryColor(widget.task.category);

    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        final theme = ThemeManager();
        final bool isCompleted = widget.task.isCompleted;

        return GestureDetector(
          onTap: _handleTap,
          child: ScaleTransition(
            scale: _scaleController,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isCompleted ? accent.withOpacity(0.15) : theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCompleted ? accent.withOpacity(0.6) : theme.textColor.withOpacity(0.05),
                  width: isCompleted ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCompleted ? accent : accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : Icon(Icons.circle_outlined, color: accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.task.title, style: TextStyle(
                          color: isCompleted ? theme.subText : theme.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: accent,
                        )),
                        Text(widget.task.category.toUpperCase(), style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text("+${widget.task.xpReward} XP", style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12)),

                  // Delete Icon
                  if (widget.onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.subText, size: 20),
                      onPressed: widget.onDelete,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}