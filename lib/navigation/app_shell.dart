import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

// Screens
import '../home/home_dashboard_page.dart';
import '../calendar/calendar_screen.dart';
import '../clock/clock_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final PageController _pageController = PageController(initialPage: 0);
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  final List<Widget> _screens = [
    const HomeDashboardPage(),
    const CalendarScreen(),
    const ClockScreen(),
    const Center(child: Text("Stats", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Profile", style: TextStyle(color: Colors.white))),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B15),
      extendBody: true,

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),

      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,

        // --- VISUAL SETTINGS ---
        color: const Color(0xFF1E1E2C),
        notchColor: const Color(0xFF6C63FF),
        showLabel: false,
        shadowElevation: 0,

        // --- SHAPE & SIZE TUNING ---
        kBottomRadius: 0.0,
        kIconSize: 24.0,     // Inactive Icon Size (Standard)
        removeMargins: true,
        circleMargin: 4.0,   // Tighter gap for a cleaner notch

        // --- ANIMATION (SMOOTHER) ---
        durationInMilliSeconds: 500, // Increased to 500ms for fluid/liquid feel

        // --- ICONS (SIZE CONTROLLED) ---
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.dashboard_outlined, color: Colors.grey),
            // Active Size = 26 (Only slightly bigger than 24)
            activeItem: Icon(Icons.dashboard_rounded, color: Colors.white, size: 26),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.calendar_month_outlined, color: Colors.grey),
            activeItem: Icon(Icons.calendar_today_rounded, color: Colors.white, size: 26),
            itemLabel: 'Calendar',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.timer_outlined, color: Colors.grey),
            activeItem: Icon(Icons.timer_rounded, color: Colors.white, size: 26),
            itemLabel: 'Clock',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.bar_chart_rounded, color: Colors.grey),
            activeItem: Icon(Icons.bar_chart_rounded, color: Colors.white, size: 26),
            itemLabel: 'Stats',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person_outline_rounded, color: Colors.grey),
            activeItem: Icon(Icons.person_rounded, color: Colors.white, size: 26),
            itemLabel: 'Profile',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
          _controller.index = index;
        },
      ),
    );
  }
}