import 'package:flutter/material.dart';

class XpController extends ChangeNotifier {
  int _totalXp = 0;

  // READ XP
  int get totalXp => _totalXp;

  // ADD XP
  void addXp(int value) {
    _totalXp += value;
    notifyListeners();
  }

  // REMOVE XP (safe)
  void removeXp(int value) {
    _totalXp = (_totalXp - value).clamp(0, 1 << 31);
    notifyListeners();
  }
}
