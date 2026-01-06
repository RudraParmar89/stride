import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class StrideBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StrideBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final Color barColor = isDark ? const Color(0xFF1E1E2C) : Colors.white; // Card color
    final Color activeCircleColor = const Color(0xFF6C63FF); // Primary Purple
    final Color iconColor = isDark ? Colors.white70 : Colors.grey;
    final Color activeIconColor = Colors.white;

    return CurvedNavigationBar(
      index: currentIndex,
      height: 60.0, // Height of the bar
      items: <Widget>[
        Icon(Icons.home_rounded, size: 30, color: currentIndex == 0 ? activeIconColor : iconColor),
        Icon(Icons.calendar_month_rounded, size: 30, color: currentIndex == 1 ? activeIconColor : iconColor),
        Icon(Icons.bar_chart_rounded, size: 30, color: currentIndex == 2 ? activeIconColor : iconColor),
        Icon(Icons.person_rounded, size: 30, color: currentIndex == 3 ? activeIconColor : iconColor),
      ],
      color: barColor,
      buttonBackgroundColor: activeCircleColor, // The floating circle color
      backgroundColor: Colors.transparent, // CRITICAL: Makes the curve transparent
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 400),
      onTap: onTap,
      letIndexChange: (index) => true,
    );
  }
}