import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Required for Provider
import 'package:firebase_auth/firebase_auth.dart'; // Required for Auth
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../controllers/xp_controller.dart'; // Import XP Controller

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  ImageProvider _getAvatarProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else if (path.isNotEmpty) {
      File file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return const AssetImage('assets/profile/astra_happy.png');
  }

  @override
  Widget build(BuildContext context) {
    // 1. ACCESS REAL DATA
    final xpController = context.watch<XpController>();
    final user = FirebaseAuth.instance.currentUser;
    // Get Name or default to "COMMANDER"
    final String displayName = user?.displayName ?? "COMMANDER";

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
                // LEFT SIDE: Avatar + Name
                Row(
                  children: [
                    // AVATAR (Hive Listener)
                    ValueListenableBuilder(
                        valueListenable: Hive.box('settingsBox').listenable(keys: ['userAvatar']),
                        builder: (context, Box box, widget) {
                          String avatarPath = box.get('userAvatar', defaultValue: 'assets/profile/astra_happy.png');

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 54,
                                height: 54,
                                child: CircularProgressIndicator(
                                  value: 0.7,
                                  strokeWidth: 2,
                                  backgroundColor: theme.subText.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
                                ),
                              ),
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.cardColor,
                                  image: DecorationImage(
                                    image: _getAvatarProvider(avatarPath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                    ),

                    const SizedBox(width: 12),

                    // NAME & TITLE (Real Data)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RISE, HUNTER",
                          style: TextStyle(
                            color: theme.subText,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayName.toUpperCase(), // <--- REAL NAME
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // RIGHT SIDE: Embers (Real Data)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: emberColor.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                              color: emberColor.withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 1
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: emberColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "${xpController.embers}", // <--- REAL EMBERS
                            style: TextStyle(
                                color: theme.textColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                fontSize: 13
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Notification Bell
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.notifications_outlined, color: theme.textColor, size: 22),
                          // Optional: Red dot logic here later
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
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
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.textColor.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(Icons.format_quote_rounded, color: theme.subText, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "The shadows await your stride.",
                      style: TextStyle(
                        color: theme.subText,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}