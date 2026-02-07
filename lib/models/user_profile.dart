import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String callsign;

  @HiveField(1)
  int age;

  @HiveField(2)
  String gender;

  @HiveField(3)
  double weight;

  @HiveField(4)
  double height;

  @HiveField(5)
  double currentStudyHours;

  @HiveField(6)
  double expectedGrindHours;

  // ✅ ADDED THIS MISSING FIELD (For Physique Logic)
  @HiveField(7)
  String? targetPhysique;

  @HiveField(8)
  DateTime? startDate;

  UserProfile({
    required this.callsign,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.currentStudyHours,
    required this.expectedGrindHours,
    this.targetPhysique,
    this.startDate,
  });

  // ---------------------------------------------------------------------------
  // ✅ JSON SERIALIZATION (REQUIRED FOR FIREBASE SYNC)
  // ---------------------------------------------------------------------------

  // 1. Convert Object -> JSON (Upload to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'callsign': callsign,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'currentStudyHours': currentStudyHours,
      'expectedGrindHours': expectedGrindHours,
      'targetPhysique': targetPhysique,
      'startDate': startDate?.toIso8601String(),
    };
  }

  // 2. Convert JSON -> Object (Download from Firebase)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      callsign: map['callsign'] ?? 'Hunter',
      age: map['age'] ?? 18,
      gender: map['gender'] ?? 'Male',
      weight: (map['weight'] ?? 70).toDouble(),
      height: (map['height'] ?? 175).toDouble(),
      currentStudyHours: (map['currentStudyHours'] ?? 0).toDouble(),
      expectedGrindHours: (map['expectedGrindHours'] ?? 4).toDouble(),
      targetPhysique: map['targetPhysique'],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
    );
  }
}