import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../controllers/task_controller.dart';
import 'quest_tile.dart';

class DailyQuestSection extends StatelessWidget {
  final List<Task> quests;
  final Function(String id) onQuestToggle;
  final Function(String id) onQuestDelete;

  const DailyQuestSection({
    super.key,
    required this.quests,
    required this.onQuestToggle,
    required this.onQuestDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ACTIVE PROTOCOLS",
                    style: TextStyle(
                        color: theme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5
                    ),
                  ),
                  Text(
                    "${quests.where((t) => !t.isCompleted).length} PENDING",
                    style: TextStyle(
                        color: theme.subText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            quests.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                children: [
                  Icon(Icons.radar_rounded, size: 48, color: theme.subText.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text(
                    "NO ACTIVE DIRECTIVES",
                    style: TextStyle(color: theme.subText, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quests.length,
              itemBuilder: (context, index) {
                final task = quests[index];

                return Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (direction) => onQuestDelete(task.id),
                  child: QuestTile(
                    task: task, // <--- FIXED: Passing the Task object directly
                    index: index,
                    onTap: () => onQuestToggle(task.id),
                    onDelete: () => onQuestDelete(task.id),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}