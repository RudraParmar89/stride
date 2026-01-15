import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import '../theme/theme_manager.dart'; // <--- IMPORT THEME MANAGER

// Screens
import '../home/home_dashboard_page.dart';
import '../calendar/calendar_screen.dart';
import '../clock/clock_screen.dart';
import '../profile/profile_screen.dart';

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
    const Center(child: Text("Stats Screen")), // Placeholder
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- FIX FOR ACTIVE ICON ONLY ---
  Widget _fixActiveIcon(IconData icon) {
    return Transform.translate(
      offset: const Offset(-1.5, -1.5),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. LISTEN TO THEME
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Scaffold(
          backgroundColor: theme.bgColor, // <--- DYNAMIC APP BACKGROUND
          extendBody: true,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
          bottomNavigationBar: AnimatedNotchBottomBar(
            notchBottomBarController: _controller,
            color: theme.cardColor,        // <--- BAR COLOR (White/Dark Grey)
            notchColor: theme.accentColor, // <--- ACTIVE CIRCLE COLOR (Red/Blue/Green)
            showLabel: false,
            shadowElevation: theme.isDark ? 0 : 5, // Add shadow in light mode for visibility

            kBottomRadius: 0.0,
            kIconSize: 24.0,
            removeMargins: true,
            circleMargin: 3.0,
            durationInMilliSeconds: 250,

            bottomBarItems: [
              // 1. HOME
              BottomBarItem(
                inActiveItem: Icon(Icons.dashboard_outlined, color: theme.subText, size: 24), // <--- DYNAMIC GREY
                activeItem: _fixActiveIcon(Icons.dashboard_rounded),
                itemLabel: 'Home',
              ),

              // 2. CALENDAR
              BottomBarItem(
                inActiveItem: Icon(Icons.calendar_month_outlined, color: theme.subText, size: 24),
                activeItem: _fixActiveIcon(Icons.calendar_today_rounded),
                itemLabel: 'Calendar',
              ),

              // 3. CLOCK
              BottomBarItem(
                inActiveItem: Icon(Icons.timer_outlined, color: theme.subText, size: 24),
                activeItem: _fixActiveIcon(Icons.timer_rounded),
                itemLabel: 'Clock',
              ),

              // 4. STATS
              BottomBarItem(
                inActiveItem: Icon(Icons.bar_chart_rounded, color: theme.subText, size: 24),
                activeItem: _fixActiveIcon(Icons.bar_chart_rounded),
                itemLabel: 'Stats',
              ),

              // 5. PROFILE
              BottomBarItem(
                inActiveItem: Icon(Icons.person_outline_rounded, color: theme.subText, size: 24),
                activeItem: _fixActiveIcon(Icons.person_rounded),
                itemLabel: 'Profile',
              ),
            ],
            onTap: (index) {
              _pageController.jumpToPage(index);
              _controller.index = index;
            },
          ),
        );
      },
    );
  }
}