import 'package:flutter/material.dart';
import '../../../theme/theme_manager.dart';

class CharacterStatsWidget extends StatelessWidget {
  final String characterName;
  final String characterClass;
  final int level;
  final double levelProgress;
  final Map<String, dynamic> stats;
  final String? characterImageUrl;

  const CharacterStatsWidget({
    super.key,
    required this.characterName,
    required this.characterClass,
    required this.level,
    required this.levelProgress,
    required this.stats,
    this.characterImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark 
        ? _createDarkTheme()
        : _createLightTheme();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.accentColor.withOpacity(0.2),
                  theme.accentColor.withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.accentColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Character Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.accentColor.withOpacity(0.4),
                        theme.accentColor.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: theme.accentColor,
                      width: 2,
                    ),
                  ),
                  child: characterImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            characterImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: theme.accentColor,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        characterName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: theme.textColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        characterClass,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.accentColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Level Progress Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.subText,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${(levelProgress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.accentColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      level.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: theme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: levelProgress,
                          minHeight: 8,
                          backgroundColor:
                              theme.cardColor.withOpacity(0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Stats Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatRow(
                  context,
                  theme,
                  icon: '❤️',
                  label: 'Health',
                  value: stats['health'] ?? 0,
                  maxValue: 100,
                  color: const Color(0xFF4ECDC4),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  theme,
                  icon: '⚔️',
                  label: 'Attack',
                  value: stats['attack'] ?? 0,
                  maxValue: 100,
                  color: const Color(0xFFEF5350),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  theme,
                  icon: '💥',
                  label: 'Damage',
                  value: stats['damage'] ?? 0,
                  maxValue: 100,
                  color: const Color(0xFFFFB74D),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  theme,
                  icon: '🛡️',
                  label: 'Defense',
                  value: stats['defense'] ?? 0,
                  maxValue: 100,
                  color: const Color(0xFF42A5F5),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  theme,
                  icon: '✨',
                  label: 'Magic Defense',
                  value: stats['magicDefense'] ?? 0,
                  maxValue: 100,
                  color: const Color(0xFFAB47BC),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  ThemeManager _createDarkTheme() {
    final theme = ThemeManager();
    return theme;
  }

  ThemeManager _createLightTheme() {
    final theme = ThemeManager();
    return theme;
  }
  Widget _buildStatRow(
    BuildContext context,
    ThemeManager theme, {
    required String icon,
    required String label,
    required int value,
    required int maxValue,
    required Color color,
  }) {
    double percentage = (value / maxValue).clamp(0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.subText,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
