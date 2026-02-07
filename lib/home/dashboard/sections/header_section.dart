import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ✅ IMPORT YOUR MODEL
import '../../../../models/user_profile.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../controllers/xp_controller.dart';
import '../../chat/chat_page.dart';

// ✅ IMPORT THE NEW NOTIFICATION PAGE
import '../../notifications/notification_page.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  ImageProvider _getAvatarProvider(String path) {
    if (path.startsWith('assets/')) return AssetImage(path);
    if (path.isNotEmpty) {
      File file = File(path);
      if (file.existsSync()) return FileImage(file);
    }
    return const AssetImage('assets/images/astra_head.png');
  }

  String _getDailyQuote() {
    final now = DateTime.now();
    final quotes = [
      "The shadows await your stride.",
      "Rise above the ordinary.",
      "Forge your path in the darkness.",
      "Strength is born in struggle.",
      "Embrace the grind, become unstoppable.",
      "Your potential is limitless.",
      "Discipline today, freedom tomorrow.",
    ];
    return quotes[now.day % quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final xpController = context.watch<XpController>();

    // 1. Get the User Box
    final userBox = Hive.box<UserProfile>('userBox');

    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();
        const Color emberColor = Color(0xFFFF9900);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT SIDE: Avatar + Name (Flexible to prevent overflow)
                Expanded(
                  child: Row(
                    children: [
                      // Avatar Watcher
                      ValueListenableBuilder(
                          valueListenable: Hive.box('settingsBox').listenable(keys: ['userAvatar']),
                          builder: (context, Box box, widget) {
                            String avatarPath = box.get('userAvatar', defaultValue: 'assets/images/astra_head.png');
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: 0.7, strokeWidth: 2, backgroundColor: theme.subText.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor))),
                                Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: theme.cardColor, image: DecorationImage(image: _getAvatarProvider(avatarPath), fit: BoxFit.cover))),
                              ],
                            );
                          }
                      ),
                      const SizedBox(width: 10),

                      // ✅ NAME WATCHER (Fixes "COMMANDER" issue)
                      Flexible(
                        child: ValueListenableBuilder(
                          valueListenable: userBox.listenable(),
                          builder: (context, Box<UserProfile> box, _) {
                            final userProfile = box.get('currentUser');
                            final name = userProfile?.callsign ?? "HUNTER";

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("RISE, HUNTER", style: TextStyle(color: theme.subText, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                    name.toUpperCase(),
                                    style: TextStyle(color: theme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // RIGHT SIDE: Embers + Chat + Notification (Compacted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. EMBERS PILL
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: emberColor.withOpacity(0.3))),
                      child: Row(children: [Icon(Icons.local_fire_department_rounded, color: emberColor, size: 14), const SizedBox(width: 4), Text("${xpController.embers}", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 12))]),
                    ),

                    const SizedBox(width: 6),

                    // 2. CHAT BUTTON
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage())),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle, border: Border.all(color: theme.accentColor.withOpacity(0.5))),
                        child: Icon(Icons.chat_bubble_rounded, color: theme.accentColor, size: 18),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // 3. NOTIFICATION BELL (Linked)
                    GestureDetector(
                      onTap: () {
                        // ✅ NAVIGATE TO SYSTEM LOG
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationPage()),
                        );
                      },
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle, boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.notifications_outlined, color: theme.textColor, size: 20),
                            Positioned(top: 8, right: 8, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // QUOTE CARD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.textColor.withOpacity(0.05))),
              child: Row(
                children: [
                  Icon(Icons.format_quote_rounded, color: theme.subText, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_getDailyQuote(), style: TextStyle(color: theme.subText, fontSize: 13, fontStyle: FontStyle.italic))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}