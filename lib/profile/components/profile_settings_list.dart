import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import '../../theme/theme_manager.dart';
import '../../services/notification_service.dart';
import 'profile_redeem_page.dart';

// --- ACHIEVEMENT MODEL ---
class Achievement {
  final String title, description, imagePath;
  final bool isUnlocked;
  Achievement({required this.title, required this.description, required this.imagePath, this.isUnlocked = false});
}

class ProfileSettingsList extends StatelessWidget {
  const ProfileSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();

    return Column(
      children: [
        _buildTile(theme, Icons.tune_rounded, "Interface Calibration", "Visual & Neural Frequency", () => _showThemeSettings(context, theme), isHighlighted: true),
        _buildTile(theme, Icons.military_tech_rounded, "Achievements", "Service Record & Badges", () => _showAchievements(context, theme)),
        _buildTile(theme, Icons.notifications_none_rounded, "Notifications", "Comms Uplink & Alerts", () => _showNotificationSettings(context, theme)),
        _buildTile(theme, Icons.security_rounded, "Privacy & Data", "Secure Hunter Protocol", () => _showPrivacySettings(context, theme)),

        // Supply Depot
        _buildTile(theme, Icons.confirmation_num_outlined, "Supply Depot", "Redeem Rewards & Gear", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TacticalRedeemPage()));
        }),

        _buildTile(theme, Icons.help_outline_rounded, "Support", "System Help Desk", () => _showSupportCenter(context, theme)),
      ],
    );
  }

  Widget _buildTile(ThemeManager theme, IconData icon, String title, String sub, VoidCallback onTap, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted ? Border.all(color: theme.accentColor.withOpacity(0.5)) : null,
        boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isHighlighted ? theme.accentColor : (theme.isDark ? Colors.white70 : Colors.black54)),
        title: Text(title, style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(sub, style: TextStyle(color: theme.subText, fontSize: 11)),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.subText),
      ),
    );
  }

  // --- FEATURE LOGIC ---

  void _showThemeSettings(BuildContext context, ThemeManager theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("INTERFACE CALIBRATION", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text("Dark Mode", style: TextStyle(color: theme.textColor)),
              value: theme.isDark,
              onChanged: (val) => theme.toggleTheme(val),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorDot(theme, const Color(0xFF00D2D3)),
                  _buildColorDot(theme, const Color(0xFF00FF41)),
                  _buildColorDot(theme, const Color(0xFFFFD700)),
                  _buildColorDot(theme, const Color(0xFFFF5252)),
                  _buildColorDot(theme, const Color(0xFF6C63FF)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(ThemeManager theme, Color color) {
    return GestureDetector(
      onTap: () { theme.setAccentColor(color); HapticFeedback.selectionClick(); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 36, height: 36,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      ),
    );
  }

  void _showAchievements(BuildContext context, ThemeManager theme) {
    final List<Achievement> achievements = [
      Achievement(title: "Early Riser", description: "Complete a task before 7 AM", imagePath: "assets/badges/Early Riser.png", isUnlocked: true),
      Achievement(title: "Midnight Scholar", description: "Task after 11 PM", imagePath: "assets/badges/Midnight Scholar.png", isUnlocked: true),
      Achievement(title: "Iron Will", description: "7 Day Streak", imagePath: "assets/badges/Internally Driven.png", isUnlocked: false),
    ];

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("SERVICE RECORD", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8),
                itemCount: achievements.length,
                itemBuilder: (c, i) => Column(
                  children: [
                    Opacity(
                      opacity: achievements[i].isUnlocked ? 1 : 0.3,
                      child: Image.asset(achievements[i].imagePath, height: 60, errorBuilder: (c,e,s) => Icon(Icons.shield, color: theme.accentColor, size: 50)),
                    ),
                    const SizedBox(height: 8),
                    Text(achievements[i].title, textAlign: TextAlign.center, style: TextStyle(color: theme.subText, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context, ThemeManager theme) {
    showModalBottomSheet(
      context: context, backgroundColor: theme.cardColor,
      builder: (c) => Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        child: Center(child: Text("Notifications Config", style: TextStyle(color: theme.textColor))),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context, ThemeManager theme) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: theme.cardColor, content: Text("PRIVACY PROTOCOLS SECURE", style: TextStyle(color: theme.accentColor))));
  }

  void _showSupportCenter(BuildContext context, ThemeManager theme) {
    Clipboard.setData(const ClipboardData(text: "support@stride.app"));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: theme.cardColor, content: Text("HQ FREQUENCY COPIED", style: TextStyle(color: theme.accentColor))));
  }
}