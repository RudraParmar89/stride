import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/theme_manager.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _userRank = 0;
  bool _isLoadingRank = true;

  @override
  void initState() {
    super.initState();
    _calculateUserRank();
  }

  Future<void> _calculateUserRank() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get all users sorted by embers
      final snapshot = await _firestore
          .collection('users')
          .orderBy('embers', descending: true)
          .get();

      final users = snapshot.docs;
      int rank = 0;
      for (int i = 0; i < users.length; i++) {
        if (users[i].id == userId) {
          rank = i + 1;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _userRank = rank;
          _isLoadingRank = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Rank calculation error: $e");
      if (mounted) {
        setState(() => _isLoadingRank = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GLOBAL LEADERBOARD",
                  style: TextStyle(
                    color: theme.subText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoadingRank)
                  SizedBox(
                    width: 100,
                    height: 20,
                    child: LinearProgressIndicator(
                      color: theme.accentColor,
                      backgroundColor: theme.accentColor.withOpacity(0.2),
                    ),
                  )
                else
                  Text(
                    "Your Rank: #$_userRank 👑",
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: theme.accentColor,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // LEADERBOARD LIST
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .orderBy('embers', descending: true)
              .limit(50) // Fetch more to ensure we get enough
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "⚠️ Error loading leaderboard: ${snapshot.error}",
                    style: TextStyle(color: theme.subText, fontSize: 12),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: theme.accentColor),
                ),
              );
            }

            final allUsers = snapshot.data?.docs ?? [];
            
            // Filter users with embers > 0 and sort by embers
            final users = allUsers
                .where((doc) => (doc['embers'] ?? 0) as int > 0)
                .toList();

            if (users.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No users with embers yet. Complete anti-cheat tasks!",
                    style: TextStyle(color: theme.subText, fontSize: 12),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.take(10).length,
              itemBuilder: (context, index) {
                final user = users[index];
                final rank = index + 1;
                final embers = (user['embers'] ?? 0) as int;
                final userName = user['userName'] ?? 'Unknown Hunter';
                final level = (user['level'] ?? 1) as int;
                final userId = user.id;
                final isCurrentUser = _auth.currentUser?.uid == userId;

                return _buildLeaderboardTile(
                  theme: theme,
                  rank: rank,
                  userName: userName,
                  embers: embers,
                  level: level,
                  isCurrentUser: isCurrentUser,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile({
    required ThemeManager theme,
    required int rank,
    required String userName,
    required int embers,
    required int level,
    required bool isCurrentUser,
  }) {
    // Rank colors
    Color rankColor = Colors.grey;
    String rankEmoji = '🏅';
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankEmoji = '🥇';
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankEmoji = '🥈';
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankEmoji = '🥉';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.accentColor.withOpacity(0.15)
            : theme.bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? theme.accentColor.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [rankColor.withOpacity(0.8), rankColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                rankEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Lv. $level",
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "YOU",
                          style: TextStyle(
                            color: theme.accentColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "#$rank on Global Leaderboard",
                  style: TextStyle(
                    color: theme.subText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Embers Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text(
                  "🔥",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  embers.toString(),
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
