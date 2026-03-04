import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import '../../theme/theme_manager.dart';
import '../../services/notification_service.dart';
import '../../services/cache_management_service.dart';
import 'profile_redeem_page.dart';
import 'privacy_terms_screens.dart';

// --- ACHIEVEMENT MODEL ---
class Achievement {
  final String title, description, imagePath;
  final bool isUnlocked;
  Achievement({required this.title, required this.description, required this.imagePath, this.isUnlocked = false});
}

class ProfileSettingsList extends StatefulWidget {
  const ProfileSettingsList({super.key});

  @override
  State<ProfileSettingsList> createState() => _ProfileSettingsListState();
}

class _ProfileSettingsListState extends State<ProfileSettingsList> {
  bool _isLoadingCache = false;
  String _cacheSize = '0 B';

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await CacheManagementService.getCacheSizeInBytes();
    setState(() {
      _cacheSize = CacheManagementService.formatBytes(size);
    });
  }

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
            Text("ACCENT COLOR", style: TextStyle(color: theme.subText, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(ThemeManager theme, Color color) {
    return GestureDetector(
      onTap: () { 
        theme.setAccentColor(color); 
        HapticFeedback.selectionClick(); 
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color, 
          shape: BoxShape.circle, 
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  void _showAchievements(BuildContext context, ThemeManager theme) {
    final List<Achievement> achievements = [
      Achievement(title: "Early Riser", description: "Complete a task before 7 AM", imagePath: "assets/badges/Early Riser.png", isUnlocked: true),
      Achievement(title: "Midnight Scholar", description: "Task after 11 PM", imagePath: "assets/badges/Midnight Scholar.png", isUnlocked: true),
      Achievement(title: "Iron Will", description: "7 Day Streak", imagePath: "assets/badges/Internally Driven.png", isUnlocked: false),
      Achievement(title: "Leaderboard Master", description: "Rank #1 in leaderboard", imagePath: "assets/badges/Leaderboard Master.png", isUnlocked: false),
      Achievement(title: "Ember Collector", description: "Earn 1000 Embers", imagePath: "assets/badges/Ember Collector.png", isUnlocked: true),
      Achievement(title: "Level Legend", description: "Reach Level 10", imagePath: "assets/badges/Level Legend.png", isUnlocked: false),
    ];

    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("SERVICE RECORD & BADGES", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: achievements.length,
                itemBuilder: (c, i) => Column(
                  children: [
                    Opacity(
                      opacity: achievements[i].isUnlocked ? 1 : 0.3,
                      child: Image.asset(
                        achievements[i].imagePath, 
                        height: 60, 
                        errorBuilder: (c,e,s) => Icon(Icons.shield, color: theme.accentColor, size: 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievements[i].title, 
                      textAlign: TextAlign.center, 
                      style: TextStyle(color: theme.subText, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
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
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("COMMS UPLINK & ALERTS", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 24),
            _buildNotificationButton(theme, '🏆 Achievement', 'New badge unlocked', () => NotificationService.sendDummyNotification('achievement')),
            const SizedBox(height: 12),
            _buildNotificationButton(theme, '⚡ Challenge Ready', 'Daily tasks available', () => NotificationService.sendDummyNotification('reminder')),
            const SizedBox(height: 12),
            _buildNotificationButton(theme, '🎯 Critical Mission', 'New task assigned', () => NotificationService.sendDummyNotification('mission')),
            const SizedBox(height: 12),
            _buildNotificationButton(theme, '🔥 Streak Alert', 'Your streak is ending soon', () => NotificationService.sendDummyNotification('streak')),
            const SizedBox(height: 12),
            _buildNotificationButton(theme, '💰 Rewards Pending', 'Embers ready to spend', () => NotificationService.sendDummyNotification('reward')),
            const SizedBox(height: 12),
            _buildNotificationButton(theme, '⬆️ Level Up', 'You reached a new level', () => NotificationService.sendDummyNotification('levelup')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(ThemeManager theme, String title, String desc, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: theme.accentColor.withOpacity(0.3)),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: theme.subText, fontSize: 10)),
                ],
              ),
            ),
            Icon(Icons.send, color: theme.accentColor, size: 18),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context, ThemeManager theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("SECURE HUNTER PROTOCOL", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14)),
            const SizedBox(height: 24),
            _buildPrivacyTile(theme, Icons.privacy_tip, "Privacy Policy", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const PrivacyAndDataScreen()));
            }),
            const SizedBox(height: 12),
            _buildPrivacyTile(theme, Icons.description, "Terms of Service", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const TermsOfServiceScreen()));
            }),
            const SizedBox(height: 12),
            _buildPrivacyTile(theme, Icons.cloud, "Data Services", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const DataServicesScreen()));
            }),
            const SizedBox(height: 12),
            _buildCacheTile(theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyTile(ThemeManager theme, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.bgColor.withOpacity(0.5),
          border: Border.all(color: theme.accentColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.accentColor),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600))),
            Icon(Icons.arrow_forward, color: theme.subText, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheTile(ThemeManager theme) {
    return GestureDetector(
      onTap: _isLoadingCache ? null : () => _clearCache(theme),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.bgColor.withOpacity(0.5),
          border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_sweep, color: const Color(0xFFFF6B6B)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Purge Local Cache", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text("Cache: $_cacheSize", style: TextStyle(color: theme.subText, fontSize: 10)),
                ],
              ),
            ),
            _isLoadingCache
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(theme.accentColor)))
                : Icon(Icons.delete, color: const Color(0xFFFF6B6B), size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCache(ThemeManager theme) async {
    setState(() => _isLoadingCache = true);
    
    try {
      await CacheManagementService.clearAllCache();
      await _loadCacheSize();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.accentColor,
            content: const Text("✓ Cache purged successfully", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF6B6B),
            content: Text("✗ Error: $e", style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCache = false);
    }
  }

  void _showSupportCenter(BuildContext context, ThemeManager theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text("SUPPORT HQ", style: TextStyle(color: theme.textColor, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email Support", style: TextStyle(color: theme.subText, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text("support@stride.app", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text("Developer", style: TextStyle(color: theme.subText, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text("Contact: dev@stride.app", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: "support@stride.app"));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: theme.cardColor, content: Text("COPIED", style: TextStyle(color: theme.accentColor)))
              );
              Navigator.pop(context);
            },
            child: const Text("Copy Email"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}