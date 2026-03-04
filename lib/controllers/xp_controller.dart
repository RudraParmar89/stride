import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class XpController extends ChangeNotifier {
  // --- CORE STATS ---
  int _currentXp = 0;
  int _level = 1;
  int _embers = 0;

  // --- RPG ATTRIBUTES (Fixes the Analytics Page Error) ---
  // STR: Strength, AGI: Agility, INT: Intellect, VIT: Vitality, SEN: Sensitivity (Focus)
  Map<String, double> _attributes = {
    'STR': 50.0,
    'AGI': 50.0,
    'INT': 50.0,
    'VIT': 50.0,
    'SEN': 50.0,
  };

  // --- GETTERS ---
  int get currentXp => _currentXp;
  int get level => _level;
  int get embers => _embers;
  Map<String, double> get attributes => _attributes; // ✅ FIXED: Now accessible
  int get totalXp => _currentXp; // For legacy compatibility

  Box? _statsBox;

  XpController() {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen('statsBox')) {
      _statsBox = await Hive.openBox('statsBox');
    } else {
      _statsBox = Hive.box('statsBox');
    }
    _loadStats();
  }

  void _loadStats() {
    if (_statsBox == null) return;

    _currentXp = _statsBox!.get('currentXp', defaultValue: 0);
    _level = _statsBox!.get('level', defaultValue: 1);
    _embers = _statsBox!.get('embers', defaultValue: 0);

    // Load Attributes safely
    final loadedAttributes = _statsBox!.get('attributes');
    if (loadedAttributes != null && loadedAttributes is Map) {
      _attributes = Map<String, double>.from(loadedAttributes);
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // ☁️ CLOUD SYNC (Realtime Leaderboard)
  // ---------------------------------------------------------------------------
  Future<void> _syncToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get user name/email from Hive
        var profileBox = await Hive.openBox('profileBox');
        String userName = profileBox.get('displayName', defaultValue: user.email ?? 'Hunter');
        String userEmail = user.email ?? 'unknown@example.com';
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'userName': userName,
          'email': userEmail,
          'currentXp': _currentXp,
          'level': _level,
          'embers': _embers, // ✅ NOW SYNCING EMBERS - CRITICAL FOR LEADERBOARD
          'attributes': _attributes,
          'rankName': getRankName(),
          'lastActive': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(), // For sorting
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("⚠️ Leaderboard Sync Failed: $e");
      }
    }
  }

  // ---------------------------------------------------------------------------
  // ⚡ GAME LOGIC
  // ---------------------------------------------------------------------------

  void addXp(int amount, {String taskCategory = "General"}) {
    _currentXp += amount;
    _checkLevelUp();

    // Improve relevant attribute based on task category
    _improveAttributeOnTaskCompletion(taskCategory);

    _save();
    _syncToCloud();
    notifyListeners();
  }

  void removeXp(int amount) {
    _currentXp = (_currentXp - amount).clamp(0, double.infinity).toInt();
    _save();
    notifyListeners();
  }

  void addEmbers(int amount) {
    _embers += amount;
    _save();
    notifyListeners();
  }

  bool spendEmbers(int amount) {
    if (_embers >= amount) {
      _embers -= amount;
      _save();
      notifyListeners();
      return true;
    }
    return false;
  }

  void _checkLevelUp() {
    // Formula: Level up every 1000 XP
    int calculatedLevel = (_currentXp / 1000).floor() + 1;
    if (calculatedLevel > _level) {
      _level = calculatedLevel;
      // Bonus embers on level up
      _embers += 50;
    }
  }

  // Improves RPG attributes based on task category (Solo Leveling style)
  void _improveAttributeOnTaskCompletion(String taskCategory) {
    double improvement = 0.8; // Base improvement per task

    switch (taskCategory.toLowerCase()) {
      case 'strength':
        _attributes['STR'] = (_attributes['STR']! + improvement * 1.5).clamp(0.0, 100.0);
        break;
      case 'cardio':
        _attributes['AGI'] = (_attributes['AGI']! + improvement * 1.2).clamp(0.0, 100.0);
        break;
      case 'intellect':
        _attributes['INT'] = (_attributes['INT']! + improvement * 1.5).clamp(0.0, 100.0);
        break;
      case 'vitality':
        _attributes['VIT'] = (_attributes['VIT']! + improvement).clamp(0.0, 100.0);
        break;
      case 'spirit':
        _attributes['SEN'] = (_attributes['SEN']! + improvement * 1.3).clamp(0.0, 100.0);
        break;
      case 'order':
        // Order tasks improve overall discipline (small boost to all)
        _attributes['STR'] = (_attributes['STR']! + improvement * 0.3).clamp(0.0, 100.0);
        _attributes['AGI'] = (_attributes['AGI']! + improvement * 0.3).clamp(0.0, 100.0);
        _attributes['INT'] = (_attributes['INT']! + improvement * 0.3).clamp(0.0, 100.0);
        _attributes['VIT'] = (_attributes['VIT']! + improvement * 0.3).clamp(0.0, 100.0);
        _attributes['SEN'] = (_attributes['SEN']! + improvement * 0.3).clamp(0.0, 100.0);
        break;
      default:
        // General tasks give small boost to INT and SEN
        _attributes['INT'] = (_attributes['INT']! + improvement * 0.5).clamp(0.0, 100.0);
        _attributes['SEN'] = (_attributes['SEN']! + improvement * 0.5).clamp(0.0, 100.0);
        break;
    }
  }

  void _save() {
    _statsBox?.put('currentXp', _currentXp);
    _statsBox?.put('level', _level);
    _statsBox?.put('embers', _embers);
    _statsBox?.put('attributes', _attributes);
  }

  String getRankName() {
    if (_level < 5) return "ROOKIE";
    if (_level < 10) return "SCOUT";
    if (_level < 20) return "VANGUARD";
    if (_level < 30) return "ELITE";
    if (_level < 50) return "COMMANDER";
    return "LEGEND";
  }
}