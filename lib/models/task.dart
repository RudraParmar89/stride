import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// ⚠️ This line is crucial. It connects the generated code.
part 'task.g.dart';

@HiveType(typeId: 2) // ✅ Kept your fix (Type ID 2)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  final int xpReward;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final bool isUserCreated;

  @HiveField(8)
  final int embersReward;

  @HiveField(9)
  final bool hasAntiChit;

  @HiveField(10)
  final int? durationMinutes; // For timed tasks (workouts, study sessions)

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.xpReward = 50,
    this.description = "",
    this.category = "General",
    required this.date,
    this.isUserCreated = false,
    this.embersReward = 0,
    this.hasAntiChit = false,
    this.durationMinutes,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? 'Untitled',
      isCompleted: map['isCompleted'] ?? false,
      xpReward: map['xpReward'] ?? 50,      embersReward: map['embersReward'] ?? 0,
      hasAntiChit: map['hasAntiChit'] ?? false,      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      isUserCreated: map['isUserCreated'] ?? false,
      durationMinutes: map['durationMinutes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'xpReward': xpReward,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'isUserCreated': isUserCreated,
      'durationMinutes': durationMinutes,
    };
  }
}