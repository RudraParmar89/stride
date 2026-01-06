import 'package:flutter/material.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _nameController = TextEditingController();
  String selectedType = "Strength";
  double difficulty = 1.0;

  final List<String> types = ["Strength", "Intellect", "Vitality", "Spirit"];

  @override
  Widget build(BuildContext context) {
    int xpReward = (difficulty * 50).toInt();

    return Container(
      padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161621),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: Color(0xFF6C63FF), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          const Text("NEW MISSION OBJECTIVE", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),

          TextField(
            controller: _nameController, // ADDED CONTROLLER
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Enter quest name...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: const Color(0xFF1E1E2C),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),

          const SizedBox(height: 24),
          const Text("CLASS TYPE", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: types.map((type) {
              final isSelected = selectedType == type;
              return ChoiceChip(
                label: Text(type),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold),
                selected: isSelected,
                selectedColor: const Color(0xFF6C63FF),
                backgroundColor: const Color(0xFF1E1E2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                onSelected: (val) => setState(() => selectedType = type),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DIFFICULTY REWARD", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text("+$xpReward XP", style: const TextStyle(color: Color(0xFF00D2D3), fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: const Color(0xFF00D2D3), inactiveTrackColor: Colors.white10, thumbColor: Colors.white, overlayColor: const Color(0xFF00D2D3).withOpacity(0.2), trackHeight: 4),
            child: Slider(
              value: difficulty, min: 1, max: 5, divisions: 4,
              onChanged: (val) => setState(() => difficulty = val),
            ),
          ),

          const SizedBox(height: 32),

          // CONFIRM BUTTON
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) return;

                // RETURN DATA TO HOME SCREEN
                Navigator.pop(context, {
                  'title': _nameController.text,
                  'subtitle': "$selectedType • Rank ${difficulty.toInt()}",
                  'xp': xpReward,
                  'isCompleted': false,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text("INITIATE QUEST", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ),
        ],
      ),
    );
  }
}