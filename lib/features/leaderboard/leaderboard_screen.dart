import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/theme_manager.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "GLOBAL RANKINGS",
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 📡 REAL-TIME STREAM
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('currentXp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text("UPLINK FAILED", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
          }

          // 3. Data Processing
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text("NO DATA FOUND", style: TextStyle(color: theme.subText)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              // Safe Data Extraction
              final String name = (data['callsign'] ?? "Unknown").toString().toUpperCase();
              final int xp = data['currentXp'] ?? 0;
              final int level = data['level'] ?? 1;
              final String uid = docs[index].id;
              
              final bool isMe = uid == currentUser?.uid;
              final int rank = index + 1;

              return _buildRankTile(theme, rank, name, xp, level, isMe);
            },
          );
        },
      ),
    );
  }

  Widget _buildRankTile(ThemeManager theme, int rank, String name, int xp, int level, bool isMe) {
    Color rankColor;
    double scale = 1.0;

    // Special Styling for Top 3
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      scale = 1.05;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = theme.subText;
    }

    return Transform.scale(
      scale: scale,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isMe ? theme.accentColor.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isMe 
              ? Border.all(color: theme.accentColor, width: 2) 
              : Border.all(color: rank == 1 ? rankColor.withOpacity(0.5) : Colors.transparent),
          boxShadow: [
            if (rank <= 3) 
              BoxShadow(color: rankColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // RANK NUMBER
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                "#$rank",
                style: TextStyle(
                  color: rankColor, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 16
                ),
              ),
            ),
            const SizedBox(width: 16),

            // AVATAR (Simple Circle)
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.bgColor,
              child: Text(
                name[0],
                style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),

            // NAME & LEVEL
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: theme.textColor, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 14,
                      letterSpacing: 0.5
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "LVL $level", 
                    style: TextStyle(
                      color: rankColor, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ],
              ),
            ),

            // XP BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "$xp",
                    style: TextStyle(
                      color: theme.textColor, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}