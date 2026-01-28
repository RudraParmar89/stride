import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// ✅ IMPORT THE MODEL
import '../models/task.dart';

class TaskController extends ChangeNotifier {
  // Access the box safely via getter.
  // main.dart guarantees this box is open as Box<Task>.
  Box<Task> get _box => Hive.box<Task>('tasks');

  // Getters
  List<Task> get tasks => _box.values.toList();

  // --- CRUD OPERATIONS ---

  void addTask(String title, {String category = "General", String description = "", int xpReward = 50}) {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      category: category,
      description: description,
      xpReward: xpReward,
      isCompleted: false,
      date: DateTime.now(),
      isUserCreated: true, // User-created task
    );

    _box.put(newTask.id, newTask);
    notifyListeners();
  }

  void addRawTask(Task task) {
    _box.put(task.id, task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    final task = _box.get(id);
    if (task != null && task.isUserCreated) {
      _box.delete(id);
      notifyListeners();
    }
  }

  Future<void> resetAllData() async {
    await _box.clear();
    notifyListeners();
  }
}
