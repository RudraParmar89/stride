import 'package:flutter/material.dart';

// 1. IMPORT THE CLOCK SCREEN
import '../../../../clock/clock_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. WRAP IN GESTURE DETECTOR
    return GestureDetector(
      onTap: () {
        // 3. NAVIGATE TO CLOCK SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ClockScreen(initialTabIndex: 0),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00D2D3).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_outlined, color: Color(0xFF00D2D3), size: 24),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "START FOCUS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    "0h 0m focused today",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                ],
              ),
            ),

            // Play Button
            const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }
}