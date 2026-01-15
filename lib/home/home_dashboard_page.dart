import 'package:flutter/material.dart';
import '../../theme/theme_manager.dart';
import '../../services/step_tracker_service.dart';

// Sections
import 'dashboard/sections/header_section.dart';
import 'dashboard/sections/progress_section.dart';
import 'dashboard/sections/hunter_bento_section.dart';
import 'dashboard/sections/quick_actions_section.dart';
import 'dashboard/sections/daily_quest_section.dart';
import 'dashboard/sections/side_quest_section.dart';
import 'dashboard/modals/add_task_sheet.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  // 1. STATE VARIABLES
  int _currentSteps = 0;
  final StepTrackerService _stepService = StepTrackerService();

  List<Map<String, dynamic>> activeQuests = [
    {'title': "Morning Run", 'subtitle': "5km • Fitness", 'xp': 150, 'isCompleted': true},
    {'title': "Deep Work", 'subtitle': "2 Hours • Study", 'xp': 150, 'isCompleted': false},
  ];

  @override
  void initState() {
    super.initState();
    _initSteps();
  }

  // 2. INIT STEPS
  void _initSteps() {
    _stepService.initService();
    setState(() {
      _currentSteps = _stepService.getSavedSteps();
    });
    _stepService.stepStream.listen((steps) {
      if (mounted) {
        setState(() {
          _currentSteps = steps;
        });
      }
    });
  }

  // 3. LOGIC: ADD NEW QUEST
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

  // 4. LOGIC: TOGGLE QUEST COMPLETION (Interactive Update)
  void _toggleQuest(int index) {
    setState(() {
      // Toggle the status
      activeQuests[index]['isCompleted'] = !activeQuests[index]['isCompleted'];

      // (Optional) Here you would also add XP to your controller
      if (activeQuests[index]['isCompleted']) {
        print("QUEST COMPLETE: +${activeQuests[index]['xp']} XP");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        final theme = ThemeManager();

        return Scaffold(
          backgroundColor: theme.bgColor,
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

                  // LIVE STEPS
                  HunterBentoSection(steps: _currentSteps),

                  const SizedBox(height: 24),
                  const QuickActionsSection(),
                  const SizedBox(height: 32),

                  // 5. CONNECTED QUEST SECTION
                  DailyQuestSection(
                    quests: activeQuests,
                    onQuestToggle: _toggleQuest, // <--- Passes the logic down
                  ),

                  const SizedBox(height: 16),
                  SideQuestSection(onTap: _openNewMissionSheet),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}