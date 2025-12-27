import 'package:flutter/material.dart';
import '../profile/profile_page.dart';
import '../calendar/calendar_screen.dart';
import '../clock/clock_screen.dart';
import '../../widgets/curved_navigation_bar.dart';
import 'dashboard_view.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DashboardView(),
          Center(child: Text("Analytics Page")),
          ProfilePage(),
          ClockScreen(),
          CalendarScreen(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          Icons.grid_view_rounded,
          Icons.insights_rounded,
          Icons.person_outline_rounded,
          Icons.access_time_rounded,
          Icons.calendar_today_rounded,
        ],
      ),
    );
  }
}
