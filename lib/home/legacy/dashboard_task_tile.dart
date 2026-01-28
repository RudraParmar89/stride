import 'package:flutter/material.dart';
import 'package:stride/theme/theme_manager.dart';

class DashboardTaskTile extends StatelessWidget {
  final Map task;
  final VoidCallback onToggle;

  const DashboardTaskTile({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task['isDone'];

    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        final theme = ThemeManager();
        return GestureDetector(
          onTap: onToggle,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(task['icon'], color: isDone ? Colors.green : theme.subText),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    task['title'],
                    style: TextStyle(
                      color: isDone ? theme.subText : theme.textColor,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Checkbox(
                  value: isDone,
                  onChanged: (_) => onToggle(),
                  activeColor: Colors.green,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
