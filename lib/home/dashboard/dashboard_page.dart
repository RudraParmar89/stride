// lib/home/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stride/controllers/theme_controller.dart';

import 'sections/header_section.dart';
import 'sections/progress_section.dart';
import 'sections/daily_quest_section.dart';
import 'sections/quick_actions_section.dart';
import 'widgets/tool_button.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeController>(context).isDark;
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF000000), const Color(0xFF161616)]
                : [const Color(0xFFFFF4E6), const Color(0xFFE0F7FA)], // Pastel peach to cyan
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: HeaderSection(greeting: greeting)),
              SliverToBoxAdapter(child: ProgressSection()),
              const DailyQuestSection(),
              SliverToBoxAdapter(child: QuickActionsSection()),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: ToolButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add new habit coming soon!")),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}