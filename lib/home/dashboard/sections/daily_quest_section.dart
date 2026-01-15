import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart';
import 'quest_tile.dart'; // Import the file you made above, or keep it in same file

class DailyQuestSection extends StatelessWidget {
  final List<Map<String, dynamic>> quests;
  final Function(int index) onQuestToggle; // <--- NEW CALLBACK

  const DailyQuestSection({
    super.key,
    required this.quests,
    required this.onQuestToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Column(
          children: [
            // HEADER
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
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(
                      "See All",
                      style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ANIMATED LIST
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quests.length,
              itemBuilder: (context, index) {
                // Pass the index for staggered delay calculation
                return QuestTile(
                  quest: quests[index],
                  index: index,
                  onTap: () => onQuestToggle(index), // Pass interaction back up
                );
              },
            ),
          ],
        );
      },
    );
  }
}