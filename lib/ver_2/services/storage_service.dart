// ignore_for_file: avoid_classes_with_only_static_members

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _currentLevelKey = 'current_level';
  static const String _completedLevelsKey = 'completed_levels';

  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  static Future<int> getCurrentLevel() async {
    final prefs = await _prefs;
    return prefs.getInt(_currentLevelKey) ?? 1;
  }

  static Future<void> setCurrentLevel(int level) async {
    final prefs = await _prefs;
    await prefs.setInt(_currentLevelKey, level);
  }

  static Future<Set<int>> getCompletedLevels() async {
    final prefs = await _prefs;
    //TODO: Верную в зад после теста
    const completedString =
        '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61'; // = prefs.getString(_completedLevelsKey) ?? '';
    if (completedString.isEmpty) return <int>{};
    return completedString.split(',').map(int.parse).toSet();
  }

  static Future<void> markLevelCompleted(int level) async {
    final prefs = await _prefs;
    final completedLevels = await getCompletedLevels();
    completedLevels.add(level);
    await prefs.setString(_completedLevelsKey, completedLevels.join(','));
  }

  static Future<bool> isLevelCompleted(int level) async {
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(level);
  }

  static Future<bool> isLevelUnlocked(int level) async {
    if (level == 1) return true; // Первый уровень всегда открыт
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(level - 1); // Уровень открыт если пройден предыдущий
  }

  static Future<void> clearProgress() async {
    final prefs = await _prefs;
    await prefs.remove(_currentLevelKey);
    await prefs.remove(_completedLevelsKey);
  }
}
