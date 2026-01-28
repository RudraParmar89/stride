import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheManagementService {
  // Clear all Hive boxes
  static Future<void> clearHiveCache() async {
    try {
      // Clear specific known boxes
      try {
        final settingsBox = await Hive.openBox('settingsBox');
        await settingsBox.clear();
      } catch (e) {
        print('Info: settingsBox not found - $e');
      }
      
      try {
        final tasksBox = await Hive.openBox('tasks');
        await tasksBox.clear();
      } catch (e) {
        print('Info: tasks box not found - $e');
      }
      
      print('✓ Hive cache cleared successfully');
    } catch (e) {
      print('✗ Error clearing Hive cache: $e');
      rethrow;
    }
  }

  // Clear app temporary directory
  static Future<void> clearTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
        tempDir.createSync();
      }
      print('✓ Temporary files cleared');
    } catch (e) {
      print('✗ Error clearing temp files: $e');
      rethrow;
    }
  }

  // Get cache size
  static Future<int> getCacheSizeInBytes() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;

      if (tempDir.existsSync()) {
        for (FileSystemEntity file in tempDir.listSync(recursive: true)) {
          if (file is File) {
            totalSize += file.lengthSync();
          }
        }
      }

      return totalSize;
    } catch (e) {
      print('✗ Error calculating cache size: $e');
      return 0;
    }
  }

  // Format bytes to readable string
  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    int i = (bytes.toString().length / 3).ceil() - 1;
    double convertedSize = bytes / pow(1000, i);
    return "${convertedSize.toStringAsFixed(2)} ${suffixes[i]}";
  }

  // Clear all cache (both Hive and temp files)
  static Future<void> clearAllCache() async {
    try {
      await clearHiveCache();
      await clearTempFiles();
      print('✓ All cache cleared successfully');
    } catch (e) {
      print('✗ Error clearing all cache: $e');
      rethrow;
    }
  }

  // Clear specific Hive box
  static Future<void> clearBox(String boxName) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.clear();
      print('✓ Box "$boxName" cleared');
    } catch (e) {
      print('✗ Error clearing box: $e');
      rethrow;
    }
  }

  // Get statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheSize = await getCacheSizeInBytes();
      
      return {
        'cacheSize': cacheSize,
        'cacheSizeFormatted': formatBytes(cacheSize),
        'boxCount': 0,
        'timestamp': DateTime.now().toString(),
      };
    } catch (e) {
      print('✗ Error getting cache stats: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}

// Helper function for power calculation
double pow(int base, int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
