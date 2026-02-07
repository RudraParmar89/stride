import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// ✅ IMPORT THE MODEL
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/task_generator_service.dart';

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

  // Reset tasks daily at midnight
  Future<void> resetDailyTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if tasks are from previous day
    final tasks = _box.values.toList();
    if (tasks.isNotEmpty && tasks.first.date.isBefore(today)) {
      await _box.clear();

      // Regenerate tasks for today
      final userBox = Hive.box<UserProfile>('userBox');
      final user = userBox.get('currentUser');
      if (user != null) {
        final newTasks = TaskGeneratorService.generateDailyQuests(user, userLevel: 1);
        for (final t in newTasks) {
          await _box.put(t.id, t);
        }
      }

      notifyListeners();
    }
  }
}
