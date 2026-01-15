import 'package:flutter/material.dart';
import '../../../../theme/theme_manager.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LISTEN TO THEME
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT SIDE: Profile + Text
                Row(
                  children: [
                    // 1. PROFILE
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: CircularProgressIndicator(
                            value: 0.7,
                            strokeWidth: 2,
                            backgroundColor: theme.subText.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor), // Dynamic Accent
                          ),
                        ),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.cardColor,
                            // Ensure you have this asset, or remove image property to see the color
                            image: const DecorationImage(
                              image: AssetImage('assets/user_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Fallback icon if image missing
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // 2. TEXT
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
                          "Commander",
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

                // RIGHT SIDE: Tokens + Bell
                Row(
                  children: [
                    // 3. TOKEN WALLET
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.textColor.withOpacity(0.05)),
                        boxShadow: theme.isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.diamond_outlined, color: theme.accentColor, size: 14), // Matches Theme
                          const SizedBox(width: 6),
                          Text(
                            "250",
                            style: TextStyle(
                                color: theme.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 4. NOTIFICATION BELL
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
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent, // Alerts stay Red usually
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
                color: theme.cardColor, // Dynamic Background
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