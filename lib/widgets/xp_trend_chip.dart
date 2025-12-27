import 'package:flutter/material.dart';

class XpTrendChip extends StatelessWidget {
  const XpTrendChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.trending_up,
              color: Color(0xFF2ECC71), size: 16),
          SizedBox(width: 6),
          Text(
            "+12% this week",
            style: TextStyle(
                color: Color(0xFF2ECC71),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
