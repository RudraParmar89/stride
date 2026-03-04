import 'dart:async';
import 'dart:convert'; // ✅ Needed for JSON
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // ✅ New HTTP package
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// ✅ Check your imports match
import '../../theme/theme_manager.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/xp_controller.dart';
import '../../config/api_config.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Box _chatBox;
  List<Map<String, dynamic>> _messages = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isTyping = false;

  static const String _apiKey = ApiConfig.groqApiKey;
  static const String _apiUrl = ApiConfig.groqApiUrl;

  @override
  void initState() {
    super.initState();
    _initHive();
    _initVoice();
  }

  // --- 1. SETUP DATABASE ---
  Future<void> _initHive() async {
    _chatBox = await Hive.openBox('chatHistory');
    if (_chatBox.isNotEmpty) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(
            _chatBox.values.map((e) => Map<String, dynamic>.from(e))
        );
      });
      Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
    } else {
      _saveMessage("astra", "Tactical Systems Online. Powered by Llama 3.3. Ready.");
    }
  }

  // --- 2. SETUP VOICE ---
  void _initVoice() {
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (val) => debugPrint('Voice Error: $val'),
        onStatus: (val) => debugPrint('Voice Status: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _controller.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // --- HELPER: SAVE & SHOW MESSAGE ---
  void _saveMessage(String sender, String text) {
    final msg = {"sender": sender, "text": text, "time": DateTime.now().toIso8601String()};
    setState(() {
      _messages.add(msg);
    });
    if (_chatBox.isOpen) _chatBox.add(msg);
    _scrollToBottom();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    _saveMessage("user", text);
    _checkForTaskIntent(text);
  }

  // --- 3. SMART TASK CREATION ---
  void _checkForTaskIntent(String text) {
    final lower = text.toLowerCase();
    if (lower.startsWith("remind me to ") || lower.startsWith("add task ")) {
      String taskTitle = text.replaceAll(RegExp(r'(?i)(remind me to |add task )'), "");
      if (taskTitle.isNotEmpty) {
        final taskController = Provider.of<TaskController>(context, listen: false);
        taskController.addTask(taskTitle, category: "General");
        _saveMessage("astra", "✅ Directive confirmed. Created task: \"$taskTitle\"");
        return;
      }
    }
    _sendMessageToGroq(text);
  }

  // --- 4. GROQ API REQUEST (Llama 3.3) ---
  Future<void> _sendMessageToGroq(String userQuery) async {
    setState(() => _isTyping = true);

    final taskController = Provider.of<TaskController>(context, listen: false);
    final xpController = Provider.of<XpController>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.displayName ?? "Hunter";

    // Build Context
    String allTasks = taskController.tasks.isEmpty
        ? "No active missions."
        : taskController.tasks.map((t) => "- ${t.title} (${t.category})").join("\n");
    String analysis = "Level ${xpController.level}, ${xpController.embers} Embers.";

    // System Prompt
    String systemPrompt = """
    You are Astra, a tactical AI companion inside an app called Stride.
    USER: $name. STATS: $analysis.
    MISSIONS:
    $allTasks
    PROTOCOL: Be helpful, witty, and concise (under 50 words). You are running on Llama 3 via Groq.
    """;

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile", // ✅ FIXED: Updated Model ID
          "messages": [
            {"role": "system", "content": systemPrompt},
            // Include last 5 messages for context memory
            ..._messages.reversed.take(5).toList().reversed.map((m) => {
              "role": m['sender'] == 'user' ? "user" : "assistant",
              "content": m['text']
            }).toList(),
            {"role": "user", "content": userQuery}
          ],
          "temperature": 0.7,
          "max_tokens": 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String botReply = data['choices'][0]['message']['content'];

        if (mounted) {
          setState(() => _isTyping = false);
          _saveMessage("astra", botReply);
        }
      } else {
        throw Exception("Groq API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        String errorMessage = "Connection severed.";
        if (e.toString().contains("Failed host lookup") || e.toString().contains("No address associated with hostname")) {
          errorMessage += " Check your internet connection.";
        } else if (e.toString().contains("401") || e.toString().contains("Unauthorized")) {
          errorMessage += " Check API Key.";
        } else {
          errorMessage += " An error occurred.";
        }
        _saveMessage("astra", "$errorMessage \nDebug: $e");
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

  void _showOptions(int index, String text, bool isUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Colors.white),
              title: const Text("Copy", style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                setState(() {
                  _messages.removeAt(index);
                  _chatBox.deleteAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF121212);
    final cardColor = const Color(0xFF1E1E1E);
    final textColor = Colors.white;
    final accentColor = Colors.cyanAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(backgroundImage: AssetImage('assets/images/astra_head.png'), radius: 14),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ASTRA ONLINE", style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle)), // Orange for Groq
                  const SizedBox(width: 4),
                  Text("Llama-3 Uplink", style: TextStyle(color: Colors.grey, fontSize: 10)),
                ]),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            onPressed: () {
              _chatBox.clear();
              setState(() => _messages.clear());
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text("Astra is thinking...", style: TextStyle(color: Colors.grey, fontSize: 10)));
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return GestureDetector(
                  onLongPress: () => _showOptions(index, msg['text'], isUser),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: isUser ? accentColor.withOpacity(0.2) : cardColor,
                        border: isUser ? Border.all(color: accentColor.withOpacity(0.5)) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['text'], style: TextStyle(color: textColor, fontSize: 14)),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _listen,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _isListening ? Colors.redAccent : bgColor, shape: BoxShape.circle),
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: textColor, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                        hintText: _isListening ? "Listening..." : "Enter directive...",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: bgColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleSubmitted(_controller.text),
                  child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle), child: const Icon(Icons.send_rounded, color: Colors.black, size: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}