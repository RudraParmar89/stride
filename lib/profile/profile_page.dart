import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 1. THEME STATE (Default to Dark)
  bool _isDarkMode = true;

  // 2. MOCK DATA
  final String userName = "Rihan";
  final String userTitle = "Level 5 Scholar";
  final int currentXP = 4250;
  final int streakDays = 12;
  final String rank = "#14";

  @override
  Widget build(BuildContext context) {
    // 3. DYNAMIC COLORS
    final bgColors = _isDarkMode
        ? [const Color(0xFF0F3D2E), const Color(0xFF000000)] // Dark Mode
        : [const Color(0xFFE0F7FA), const Color(0xFFFFFFFF)]; // Light Mode

    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = _isDarkMode ? Colors.white54 : Colors.black54;

    // Glass effect colors
    final glassColor = _isDarkMode
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.6);

    final borderColor = _isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    final accentColor = const Color(0xFF2ECC71); // Stride Green

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // --- THEME TOGGLE BUTTON ---
          GestureDetector(
            onTap: () => setState(() => _isDarkMode = !_isDarkMode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 20, top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: glassColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: _isDarkMode ? accentColor.withOpacity(0.2) : Colors.black12,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: _isDarkMode ? Colors.yellow : Colors.grey[800],
                size: 20,
              ),
            ),
          )
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
        child: Stack(
          children: [
            // --- FIXED: DECORATIVE GLOW (The error was here) ---
            Positioned(
              top: -80, left: -50,
              child: Container(
                height: 300, width: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent, // Background color irrelevant for shadow
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(_isDarkMode ? 0.3 : 0.2),
                      blurRadius: 120, // Creating the glow
                      spreadRadius: 20,
                    )
                  ],
                ),
              ),
            ),

            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 10),

                  // 4. PROFILE HEADER
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating Glow Ring
                        Container(
                          height: 125, width: 125,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.25),
                                blurRadius: 40,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                        ),
                        // Avatar Image
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          child: const CircleAvatar(
                            radius: 54,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                          ),
                        ),
                        // Edit Badge
                        Positioned(
                          bottom: 5, right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: _isDarkMode ? Colors.black : Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name & Title
                  Column(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          userTitle,
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // 5. STATS GRID
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              "Total XP", "$currentXP", Icons.bolt_rounded, Colors.orange,
                              glassColor, textColor, borderColor
                          )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildStatCard(
                              "Streak", "$streakDays Days", Icons.local_fire_department_rounded, Colors.redAccent,
                              glassColor, textColor, borderColor
                          )
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rank Card
                  _buildStatCard(
                      "Global Rank", rank, Icons.emoji_events_rounded, Colors.yellow,
                      glassColor, textColor, borderColor, isWide: true
                  ),

                  const SizedBox(height: 40),

                  // 6. SETTINGS MENU
                  Text("Preferences", style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 15),

                  _buildMenuTile(Icons.person_outline_rounded, "Account Settings", glassColor, textColor, borderColor),
                  _buildMenuTile(Icons.notifications_outlined, "Notifications", glassColor, textColor, borderColor),
                  _buildMenuTile(Icons.shield_outlined, "Privacy & Data", glassColor, textColor, borderColor),
                  _buildMenuTile(Icons.headset_mic_outlined, "Help & Support", glassColor, textColor, borderColor),

                  const SizedBox(height: 30),

                  // 7. LOGOUT BUTTON
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logout Clicked")));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.withOpacity(0.8), Colors.red.shade900],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Log Out",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor, Color glassColor, Color textColor, Color borderColor, {bool isWide = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (isWide) const SizedBox(width: 20),
              if (!isWide) const SizedBox(width: 0),

              Column(
                crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  if (!isWide) const SizedBox(height: 12),
                  Text(
                      value,
                      style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  Text(
                      label,
                      style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500)
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, Color glassColor, Color textColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(icon, color: textColor.withOpacity(0.7), size: 22),
                const SizedBox(width: 16),
                Text(
                    title,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: textColor.withOpacity(0.4), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}