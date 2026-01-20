import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../theme/theme_manager.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/xp_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  // --- API CONFIGURATION ---
  // ⚠️ SECURITY WARNING: Never commit this key to GitHub or share it publicly.
  static const String _apiKey = 'AIzaSyDvyFTQ3klIcu1ZANRjwhzlrAUzdB9oMUg';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _initModel();
    _addSystemMessage("Astra Systems Online. Syncing complete. How can I assist?");
  }

  void _initModel() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
    _chatSession = _model.startChat();
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add({"sender": "astra", "text": text});
    });
    _scrollToBottom();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isTyping = true;
    });
    _scrollToBottom();

    _generateOmniscientResponse(text);
  }

  // --- THE OMNISCIENT BRAIN ---
  Future<void> _generateOmniscientResponse(String userQuery) async {
    try {
      // 1. DATA AGGREGATION (Gathering "Everything")
      final taskController = Provider.of<TaskController>(context, listen: false);
      final xpController = Provider.of<XpController>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;

      // A. User Details
      final String name = user?.displayName ?? "Commander";
      final String email = user?.email ?? "Unknown";

      // B. Missions (Defined & User Created)
      String allTasks = taskController.tasks.isEmpty
          ? "No missions active."
          : taskController.tasks.map((t) {
        String status = t.isCompleted ? "[COMPLETED]" : "[PENDING]";
        return "$status ${t.title} (Class: ${t.category}, Reward: ${t.xpReward} XP)";
      }).join("\n");

      // C. Analysis & Stats
      String analysis = """
      - Level: ${xpController.level}
      - Current XP: ${xpController.currentXp}
      - Rank: ${xpController.getRankName()}
      - Embers (Currency): ${xpController.embers}
      """;

      // D. Focus Timer & Calendar (Placeholders)
      bool isFocusActive = false;
      String focusTimeRemaining = "00:00";
      String calendarEvents = "No external calendar events synced.";

      // 2. CONSTRUCT THE SYSTEM PROMPT
      String systemContext = """
      You are Astra, a tactical AI interface for the Stride productivity app.
      
      INSTRUCTIONS:
      1. You have FULL ACCESS to the user's data below.
      2. Be PRECISE and CONCISE. Do not ramble.
      3. Answer ONLY what is asked based on the data.
      4. If the user asks about "Missions", "Tasks", "Stats", "Focus", or "Calendar", use the provided data.
      
      --- LIVE DATA FEED ---
      USER: $name ($email)
      
      ANALYSIS:
      $analysis
      
      FOCUS TIMER STATUS:
      - Active: $isFocusActive
      - Time Remaining: $focusTimeRemaining
      
      CALENDAR / MISSIONS LOG:
      $allTasks
      $calendarEvents
      ----------------------
      
      USER QUERY: $userQuery
      """;

      // 3. SEND TO AI
      final response = await _chatSession.sendMessage(
          Content.text(systemContext)
      );

      final responseText = response.text ?? "Data packet lost. Please retry.";

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({"sender": "astra", "text": responseText});
        });
        _scrollToBottom();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({"sender": "astra", "text": "Connection failure. Offline protocols active."});
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
          appBar: AppBar(
            backgroundColor: theme.cardColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.accentColor.withOpacity(0.2),
                  backgroundImage: const AssetImage('assets/profile/astra_happy.png'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ASTRA ONLINE", style: TextStyle(color: theme.textColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text("Systems Synced", style: TextStyle(color: theme.subText, fontSize: 10)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) return _buildTypingIndicator(theme);
                    final msg = _messages[index];
                    final isUser = msg['sender'] == 'user';
                    return _buildMessageBubble(theme, msg['text']!, isUser);
                  },
                ),
              ),
              _buildInputArea(theme),
            ],
          ),
        );
      },
    );
  }

  // --- UI WIDGETS ---

  Widget _buildMessageBubble(ThemeManager theme, String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? theme.accentColor : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : theme.textColor,
            fontSize: 13,
            height: 1.4,
            fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeManager theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
        ),
        child: SizedBox(
          width: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _dot(theme), _dot(theme), _dot(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(ThemeManager theme) {
    return Container(width: 5, height: 5, decoration: BoxDecoration(color: theme.subText, shape: BoxShape.circle));
  }

  Widget _buildInputArea(ThemeManager theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: theme.textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Enter directive...",
                hintStyle: TextStyle(color: theme.subText, fontSize: 13),
                filled: true,
                fillColor: theme.bgColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                isDense: true,
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _handleSubmitted(_controller.text),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: theme.accentColor, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}