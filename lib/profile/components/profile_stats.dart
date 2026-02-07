import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_manager.dart'; // Adjust path
// ✅ IMPORT LEADERBOARD SCREEN
import '../../../features/leaderboard/leaderboard_screen.dart'; // Ensure you have this file created as per previous step

class ProfileStats extends StatelessWidget {
  final int xp;
  final int streak;
  final int quests;
  final int globalRank;

  const ProfileStats({
    super.key,
    required this.xp,
    required this.streak,
    required this.quests,
    required this.globalRank,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(children: [
            _buildStat(context, theme, "TOTAL XP", xp.toString(), Icons.bolt_rounded, const Color(0xFFFFD700), flex: 1.2),
            const SizedBox(width: 12),
            _buildStat(context, theme, "STREAK", streak.toString(), Icons.local_fire_department_rounded, Colors.orangeAccent, flex: 1),
          ]),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(children: [
            _buildStat(context, theme, "QUESTS", quests.toString(), Icons.verified_rounded, theme.accentColor, flex: 1),
            const SizedBox(width: 12),

            // ✅ LEADERBOARD TILE (Clickable)
            _buildStat(
                context,
                theme,
                "GLOBAL RANK",
                "#$globalRank",
                Icons.leaderboard_rounded,
                const Color(0xFF6C63FF),
                flex: 1.2,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LeaderboardScreen())
                  );
                }
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, ThemeManager theme, String label, String value, IconData icon, Color color, {required double flex, VoidCallback? onTap}) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: GestureDetector(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: theme.cardColor,
                  content: Text("> SYNCING DATA...", style: TextStyle(color: theme.accentColor, fontFamily: 'Courier'))
              )
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 12),
              FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(color: theme.textColor, fontSize: 22, fontWeight: FontWeight.w900))),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: theme.subText, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}