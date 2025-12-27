import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  // FORM CONTROLLERS
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // STATE VARIABLES
  String _selectedCategory = 'Study';
  String _difficulty = 'Medium';
  int _xpReward = 30;

  final List<String> _categories = ['Study', 'Health', 'Fitness', 'Code', 'Art'];

  void _updateDifficulty(String level) {
    setState(() {
      _difficulty = level;
      if (level == 'Easy') _xpReward = 10;
      if (level == 'Medium') _xpReward = 30;
      if (level == 'Hard') _xpReward = 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback color
      body: Container(
        // GLOBAL BACKGROUND GRADIENT (Matches Dashboard)
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.5), // Light source from top right
            radius: 1.3,
            colors: [
              Color(0xFF0F3D2E), // Deep Emerald Green
              Color(0xFF000000), // Pure Black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. CUSTOM APP BAR
              _buildAppBar(context),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // 2. HEADER TEXT
                    const Text(
                      "New Quest",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Define your goal and set your rewards.",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),

                    const SizedBox(height: 40),

                    // 3. TITLE INPUT
                    _buildLabel("HABIT TITLE"),
                    _buildGlassInput(_titleController, "e.g., Read 10 Pages", Icons.edit),

                    const SizedBox(height: 25),

                    // 4. CATEGORY SELECTION
                    _buildLabel("CATEGORY"),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2ECC71) : const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2ECC71) : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 5. DIFFICULTY & XP REWARD
                    _buildLabel("DIFFICULTY LEVEL"),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: ['Easy', 'Medium', 'Hard'].map((level) {
                          final isSelected = _difficulty == level;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _updateDifficulty(level),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF2ECC71) : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // XP PREVIEW CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt, color: Color(0xFF2ECC71)),
                          const SizedBox(width: 8),
                          Text(
                            "Completion Reward: +$_xpReward XP",
                            style: const TextStyle(
                              color: Color(0xFF2ECC71),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 6. TIME INPUT
                    _buildLabel("TIME SCHEDULE"),
                    _buildGlassInput(_timeController, "e.g., 10:00 AM", Icons.access_time),
                  ],
                ),
              ),

              // 7. CREATE BUTTON (Fixed at Bottom)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: () {
                    // Logic to return data
                    Navigator.pop(context, {
                      "title": _titleController.text,
                      "category": _selectedCategory,
                      "xp": _xpReward,
                      "time": _timeController.text,
                    });
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF26A69A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Create Quest",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          const Text("Create Habit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          const SizedBox(width: 40), // Balance the row
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGlassInput(TextEditingController controller, String hint, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.grey[600]),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}