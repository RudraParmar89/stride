import 'package:flutter/material.dart';

// Sections
import 'dashboard/sections/header_section.dart';
import 'dashboard/sections/progress_section.dart';
import 'dashboard/sections/hunter_bento_section.dart';
import 'dashboard/sections/quick_actions_section.dart';
import 'dashboard/sections/daily_quest_section.dart';
import 'dashboard/sections/side_quest_section.dart';
import 'dashboard/modals/add_task_sheet.dart'; // Import Modal

// Must be StatefulWidget to hold data
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  // 1. STATE: This list holds your tasks
  List<Map<String, dynamic>> activeQuests = [
    {'title': "Morning Run", 'subtitle': "5km • Fitness", 'xp': 150, 'isCompleted': true},
    {'title': "Deep Work", 'subtitle': "2 Hours • Study", 'xp': 150, 'isCompleted': false},
  ];

  // 2. LOGIC: Function to open modal and add result
  void _openNewMissionSheet() async {
    final newQuest = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(),
    );

    if (newQuest != null) {
      setState(() {
        activeQuests.add(newQuest);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0B0B15);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const HeaderSection(),
              const SizedBox(height: 28),
              const ProgressSection(),
              const SizedBox(height: 24),
              const HunterBentoSection(),
              const SizedBox(height: 24),
              const QuickActionsSection(),
              const SizedBox(height: 32),

              // 3. PASS DATA: Give the list to the section
              DailyQuestSection(quests: activeQuests),

              const SizedBox(height: 16),

              // 4. PASS LOGIC: Give the function to the button
              SideQuestSection(onTap: _openNewMissionSheet),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}