import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
// ✅ IMPORT THE TASK MODEL
import '../models/task.dart';

class SyncService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // --- UPLOAD DATA (Local -> Cloud) ---
  static Future<void> uploadData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Upload Profile
      final userBox = Hive.box<UserProfile>('userBox');
      final currentUser = userBox.get('currentUser');

      if (currentUser != null) {
        await _db.collection('users').doc(user.uid).set(
          currentUser.toMap(),
          SetOptions(merge: true),
        );
      }

      // 2. Upload Tasks
      // ✅ Now Hive.box<Task> works because we imported the model
      final taskBox = Hive.box<Task>('tasks');
      final tasks = taskBox.values.toList();

      final batch = _db.batch();
      final tasksRef = _db.collection('users').doc(user.uid).collection('tasks');

      // Clear old cloud tasks (optional strategy, but simple for now)
      // Note: Real sync usually diffs data. For now, we overwrite.
      var snapshots = await tasksRef.get();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }

      for (var task in tasks) {
        final docRef = tasksRef.doc(task.id);
        batch.set(docRef, task.toMap());
      }

      await batch.commit();
      debugPrint("✅ Data Synced to Cloud");

    } catch (e) {
      debugPrint("⚠️ Sync Upload Failed: $e");
    }
  }

  // --- DOWNLOAD DATA (Cloud -> Local) ---
  static Future<void> downloadData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Download Profile
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final userProfile = UserProfile.fromMap(data);

        final userBox = Hive.box<UserProfile>('userBox');
        await userBox.put('currentUser', userProfile);
      }

      // 2. Download Tasks
      final tasksSnapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .get();

      if (tasksSnapshot.docs.isNotEmpty) {
        final taskBox = Hive.box<Task>('tasks');
        await taskBox.clear(); // Replace local with cloud

        for (var doc in tasksSnapshot.docs) {
          // ✅ Task.fromMap works because we imported the model
          final task = Task.fromMap(doc.data());
          await taskBox.put(task.id, task);
        }
      }
      debugPrint("✅ Data Downloaded from Cloud");

    } catch (e) {
      debugPrint("⚠️ Sync Download Failed: $e");
    }
  }
}