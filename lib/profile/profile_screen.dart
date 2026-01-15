import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/theme_manager.dart'; // <--- CONNECTING TO THE BRAIN

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  // --- ANIMATION STATE ---
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  bool _isGlitching = false;
  Timer? _glitchTimer;

  // --- FIREBASE USER ---
  final User? user = FirebaseAuth.instance.currentUser;
  String get userName => user?.displayName?.toUpperCase() ?? "COMMANDER";
  String get userId => user?.uid ?? "GUEST-001";
  String get shortId => userId.length > 4 ? userId.substring(userId.length - 4).toUpperCase() : userId;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut));
    _startGlitchLoop();
  }

  void _startGlitchLoop() {
    _glitchTimer = Timer.periodic(Duration(seconds: 3 + Random().nextInt(5)), (timer) {
      if (mounted) _triggerGlitch();
    });
  }

  void _triggerGlitch() {
    setState(() => _isGlitching = true);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isGlitching = false);
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _glitchTimer?.cancel();
    super.dispose();
  }

  // --- MODALS AND ACTIONS ---

  void _showIdentityCard(ThemeManager theme) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.bgColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.accentColor.withOpacity(0.5), width: 2),
              boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("IDENTITY CARD", style: TextStyle(color: theme.subText, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                  child: QrImageView(
                    data: "uid:$userId|name:$userName",
                    version: QrVersions.auto,
                    size: 180.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(userName, style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.accentColor.withOpacity(0.3)),
                  ),
                  child: Text("UNIT #$shortId", style: TextStyle(color: theme.accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 24),
                Text("SCAN TO VERIFY CREDENTIALS", style: TextStyle(color: theme.subText, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTacticalToast(String message, ThemeManager theme) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(side: BorderSide(color: theme.accentColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            Icon(Icons.terminal, color: theme.accentColor, size: 16),
            const SizedBox(width: 12),
            Expanded(child: Text(message.toUpperCase(), style: TextStyle(color: theme.textColor, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  void _openCommandConsole(String title, Widget content, ThemeManager theme) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.bgColor.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: theme.accentColor.withOpacity(0.5))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.settings_suggest_rounded, color: theme.accentColor, size: 20), const SizedBox(width: 12), Text("CONFIG // $title", style: TextStyle(color: theme.textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5))]),
            Divider(color: theme.subText.withOpacity(0.2), height: 30),
            content,
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () {Navigator.pop(context); _showTacticalToast("CONFIGURATION UPDATED", theme);}, child: const Text("APPLY CHANGES", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)))),
          ],
        ),
      ),
    );
  }

  void _showLogoutWarning(ThemeManager theme) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.redAccent.withOpacity(0.5)), borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent), SizedBox(width: 12), Text("WARNING", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))]),
        content: Text("ABORTING SESSION WILL DISCONNECT NEURAL LINK.\n\nARE YOU SURE YOU WANT TO PROCEED?", style: TextStyle(color: theme.subText, fontSize: 13)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL", style: TextStyle(color: theme.subText))), TextButton(onPressed: () {Navigator.pop(context); _showTacticalToast("SESSION ABORTED. LOGGING OUT...", theme); FirebaseAuth.instance.signOut(); }, child: const Text("ABORT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))],
      ),
    );
  }

  // --- BUILD HELPERS (CONNECTED TO THEME MANAGER) ---

  Widget _buildAppearanceMenu(ThemeManager theme, StateSetter modalSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // THEME MODE SWITCH
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("STEALTH MODE (DARK)", style: TextStyle(color: theme.textColor, fontSize: 14)),
            Switch(
              value: theme.isDark,
              onChanged: (val) {
                // GLOBAL THEME UPDATE
                theme.toggleTheme(val);
                modalSetState(() {}); // Refresh Modal
              },
              activeColor: theme.accentColor,
              activeTrackColor: theme.accentColor.withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text("HUD ACCENT COLOR", style: TextStyle(color: theme.subText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildColorOption(theme, const Color(0xFF00D2D3), "CYAN", modalSetState),
            _buildColorOption(theme, const Color(0xFF6C63FF), "VOID", modalSetState),
            _buildColorOption(theme, const Color(0xFF00FF41), "BIO", modalSetState),
            _buildColorOption(theme, const Color(0xFFFF2E2E), "ALERT", modalSetState),
            _buildColorOption(theme, const Color(0xFFFFD700), "GOLD", modalSetState),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(ThemeManager theme, Color color, String label, StateSetter modalSetState) {
    final bool isSelected = theme.accentColor == color;
    return GestureDetector(
      onTap: () {
        // GLOBAL COLOR UPDATE
        theme.setAccentColor(color);
        modalSetState(() {});
      },
      child: Column(
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? theme.textColor : color.withOpacity(0.5), width: 2),
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 15)] : [],
            ),
            child: isSelected ? Icon(Icons.check, color: theme.textColor, size: 20) : null,
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isSelected ? theme.textColor : theme.subText, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(ThemeManager theme, String label, bool value, [Function(bool)? onChanged]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.textColor, fontSize: 14)),
        Switch(
          value: value,
          onChanged: onChanged ?? (v) {},
          activeColor: theme.accentColor,
          activeTrackColor: theme.accentColor.withOpacity(0.3),
        ),
      ],
    );
  }

  // --- MAIN BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    // WRAP EVERYTHING IN LISTENABLE BUILDER TO LISTEN TO THEME CHANGES
    return ListenableBuilder(
        listenable: ThemeManager(),
        builder: (context, child) {
          final theme = ThemeManager(); // ACCESS GLOBAL THEME

          return Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: Container(
                  color: theme.bgColor,
                  child: Opacity(
                    opacity: theme.isDark ? 0.03 : 0.05,
                    child: SvgPicture.asset('assets/textures/circuit_pattern.svg', fit: BoxFit.cover, colorFilter: ColorFilter.mode(theme.textColor, BlendMode.srcIn)),
                  ),
                ),
              ),

              Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RotatedBox(
                            quarterTurns: 3,
                            child: Text("UNIT #$shortId",
                              style: TextStyle(color: theme.subText, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(onTap: _triggerGlitch, child: _buildGlitchAvatar(theme, theme.accentColor)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _isGlitching ? _buildGlitchText(userName, theme) : Text(userName, style: TextStyle(color: theme.textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                    const SizedBox(width: 8),
                                    _buildPulsingStatusDot(),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text("Level 12", style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                      child: const Text("Rank S", style: TextStyle(color: Colors.yellow, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(onTap: () => _showIdentityCard(theme), child: _buildAnimatedScanner(theme)),
                        ],
                      ),

                      const SizedBox(height: 32),
                      Text("TACTICAL STATUS", style: TextStyle(color: theme.subText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 16),

                      // STATS (Passing theme)
                      IntrinsicHeight(child: Row(children: [_buildMosaicStat(theme, "TOTAL XP", "24.5k", Icons.bolt_rounded, const Color(0xFFFFD700), flex: 1.2, onTap: () => _showTacticalToast("> DOWNLOADING XP LOGS...", theme)), const SizedBox(width: 12), _buildMosaicStat(theme, "STREAK", "12", Icons.local_fire_department_rounded, Colors.orangeAccent, flex: 1, onTap: () => _showTacticalToast("> SYNCING STREAK DATA...", theme))])),
                      const SizedBox(height: 12),
                      IntrinsicHeight(child: Row(children: [_buildMosaicStat(theme, "QUESTS", "48", Icons.verified_rounded, theme.accentColor, flex: 1, onTap: () => _showTacticalToast("> RETRIEVING QUEST ARCHIVE...", theme)), const SizedBox(width: 12), _buildMosaicStat(theme, "GLOBAL RANK", "#42", Icons.leaderboard_rounded, const Color(0xFF6C63FF), flex: 1.2, onTap: () => _showTacticalToast("> UPDATING LEADERBOARD...", theme))])),

                      const SizedBox(height: 32),

                      Text("SYSTEM SETTINGS", style: TextStyle(color: theme.subText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 16),

                      _buildSystemTile(theme, Icons.notifications_none_rounded, "Notifications", "Alert Frequency", onTap: () => _openCommandConsole("ALERTS", _buildSwitchRow(theme, "Push Notifications", true), theme)),

                      _buildSystemTile(
                        theme,
                        Icons.security_rounded,
                        "Privacy & Data",
                        "Secure Hunter Protocol",
                        onTap: () => _openCommandConsole(
                            "DATA_PROTOCOL",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSwitchRow(theme, "Share Data for AI Training", true),
                                const SizedBox(height: 12),
                                Text(
                                  "Allow the system to analyze your habit patterns to enhance the tactical algorithm for future hunters.",
                                  style: TextStyle(color: theme.subText, fontSize: 11, height: 1.4),
                                ),
                              ],
                            ),
                            theme
                        ),
                      ),

                      // APPEARANCE TILE (NOW GLOBAL)
                      _buildSystemTile(
                        theme,
                        Icons.palette_outlined,
                        "Appearance",
                        "Visual Protocols",
                        onTap: () => _openCommandConsole(
                            "VISUALS",
                            StatefulBuilder(builder: (context, setState) => _buildAppearanceMenu(theme, setState)),
                            theme
                        ),
                      ),

                      _buildSystemTile(theme, Icons.help_outline_rounded, "Support", "System Help Desk", onTap: () => _showTacticalToast("CONNECTING TO HQ...", theme)),

                      const SizedBox(height: 24),
                      GestureDetector(onTap: () => _showLogoutWarning(theme), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.redAccent.withOpacity(0.05), border: Border.all(color: Colors.redAccent.withOpacity(0.2))), child: const Center(child: Text("ABORT SESSION", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 2))))),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
    );
  }

  // --- REUSABLE WIDGETS (UPDATED FOR GLOBAL THEME) ---

  Widget _buildMosaicStat(ThemeManager theme, String label, String value, IconData icon, Color color, {required double flex, VoidCallback? onTap}) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: GestureDetector(
        onTap: onTap,
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: TextStyle(color: theme.textColor, fontSize: 22, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: theme.subText, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemTile(ThemeManager theme, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: theme.isDark ? Colors.white70 : Colors.black54, size: 22),
        title: Text(title, style: TextStyle(color: theme.textColor, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.subText, fontSize: 11)),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.isDark ? Colors.white38 : Colors.black26, size: 18),
      ),
    );
  }

  Widget _buildGlitchAvatar(ThemeManager theme, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: _isGlitching
          ? Matrix4.translationValues(Random().nextDouble() * 4 - 2, Random().nextDouble() * 4 - 2, 0)
          : Matrix4.identity(),
      width: 60, height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _isGlitching ? theme.textColor : color, width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(_isGlitching ? 0.8 : 0.2), blurRadius: _isGlitching ? 20 : 10)],
      ),
      child: Center(child: Icon(Icons.person_rounded, color: theme.textColor, size: 30)),
    );
  }

  Widget _buildGlitchText(String text, ThemeManager theme) {
    return Stack(
      children: [
        Transform.translate(offset: const Offset(-2, 0), child: Text(text, style: const TextStyle(color: Colors.cyanAccent, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1))),
        Transform.translate(offset: const Offset(2, 0), child: Text(text, style: const TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1))),
        Text(text, style: TextStyle(color: theme.textColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildPulsingStatusDot() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.2, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, double opacity, child) {
        return Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF00FF41).withOpacity(opacity),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: const Color(0xFF00FF41).withOpacity(opacity), blurRadius: 6)],
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildAnimatedScanner(ThemeManager theme) {
    return SizedBox(
      width: 30, height: 30,
      child: Stack(
        children: [
          Center(child: Icon(Icons.qr_code_2_rounded, color: theme.isDark ? Colors.white30 : Colors.black26, size: 30)),
          AnimatedBuilder(
            animation: _scannerAnimation,
            builder: (context, child) {
              return Positioned(
                top: _scannerAnimation.value * 28,
                child: Container(
                  width: 30, height: 2,
                  decoration: BoxDecoration(color: theme.accentColor, boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.8), blurRadius: 4)]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}