import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../models/task.dart';
import '../widgets/task_card.dart'; // ✅ Import the widget

import 'package:stride/features/active_session/run_tracker_page.dart';
import 'package:stride/features/active_session/meditation_session_page.dart';

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

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'STRENGTH': case 'WORKOUT': return Colors.redAccent;
      case 'CARDIO': case 'RUN': return Colors.orangeAccent;
      case 'SPIRIT': case 'MEDITATION': return Colors.amber;
      case 'ORDER': case 'DISCIPLINE': return Colors.blueAccent;
      case 'GROWTH': case 'LEARNING': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _handleTaskTap(BuildContext context, Task task) {
    // ... (Keep your existing tap logic here)
    String title = task.title.toLowerCase();
    bool isCardio = title.contains("run") || title.contains("walk") || title.contains("jog");
    bool isMeditation = title.contains("meditat") || title.contains("mindful") || title.contains("reset");

    if (!task.isCompleted) {
      if (isCardio) {
        _showTrackerOptions(context, task);
      } else if (isMeditation) {
        _startMeditation(context, task);
      } else {
        onQuestToggle(task.id);
      }
    } else {
      onQuestToggle(task.id);
    }
  }

  // ... (Keep _startMeditation and _showTrackerOptions logic)
  void _startMeditation(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MeditationSessionPage(taskName: task.title)),
    ).then((result) {
      if (result == true) onQuestToggle(task.id);
    });
  }

  void _showTrackerOptions(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeManager().cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_run_rounded, size: 50, color: Colors.orangeAccent),
            const SizedBox(height: 10),
            Text("Time to Move", style: TextStyle(color: ThemeManager().textColor, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.gps_fixed_rounded),
                label: const Text("Start Session"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RunTrackerPage(taskName: task.title)),
                  ).then((result) {
                    if (result == true) onQuestToggle(task.id);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  Text("ACTIVE PROTOCOLS", style: TextStyle(color: theme.textColor, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text("${quests.where((t) => !t.isCompleted).length} PENDING", style: TextStyle(color: theme.subText, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            quests.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text("NO ACTIVE DIRECTIVES", style: TextStyle(color: theme.subText)),
            )
                : ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quests.length,
              itemBuilder: (context, index) {
                final task = quests[index];

                // 1. Define the Card with Data
                final card = TaskCard(
                  title: task.title,
                  tag: task.category.toUpperCase(),
                  xp: task.xpReward,
                  embers: task.embersReward,
                  color: _getCategoryColor(task.category),
                  isCompleted: task.isCompleted,
                  hasAntiChit: task.hasAntiChit,
                  isUserCreated: task.isUserCreated,
                  description: task.description ?? "No description available.",
                  onTap: () => _handleTaskTap(context, task),
                  onDelete: () => onQuestDelete(task.id),
                );

                // 2. Wrap user tasks in Dismissible
                return task.isUserCreated
                    ? Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) => onQuestDelete(task.id),
                  child: card,
                )
                    : card;
              },
            ),
          ],
        );
      },
    );
  }
}