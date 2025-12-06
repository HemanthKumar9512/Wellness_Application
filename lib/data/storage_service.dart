import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'wellness_model.dart';

class StorageService {
  static const String _metricsKey = 'wellness_metrics';
  static const String _goalsKey = 'user_goals';
  static const String _darkModeKey = 'dark_mode';
  static const String _remindersKey = 'daily_reminders';

  static Future<void> saveMetrics(List<WellnessMetric> metrics) async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = metrics.map((m) => m.toJson()).toList();
    await prefs.setStringList(_metricsKey, metricsJson);
  }

  static Future<List<WellnessMetric>> loadMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getStringList(_metricsKey) ?? [];

    if (metricsJson.isEmpty) {
      return _generateInitialData();
    }

    return metricsJson.map((json) => WellnessMetric.fromJson(json)).toList();
  }

  static Future<void> saveMetric(WellnessMetric metric) async {
    final metrics = await loadMetrics();
    final index = metrics.indexWhere((m) =>
        m.date.year == metric.date.year &&
        m.date.month == metric.date.month &&
        m.date.day == metric.date.day);

    if (index >= 0) {
      metrics[index] = metric;
    } else {
      metrics.add(metric);
    }

    await saveMetrics(metrics);
  }

  static Future<WellnessMetric?> getMetricForDate(DateTime date) async {
    final metrics = await loadMetrics();
    for (var metric in metrics) {
      if (metric.date.year == date.year &&
          metric.date.month == date.month &&
          metric.date.day == date.day) {
        return metric;
      }
    }
    return null;
  }

  static Future<void> saveGoals(UserGoals goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsMap = goals.toMap();
    final goalsJson = json.encode(goalsMap);
    await prefs.setString(_goalsKey, goalsJson);
  }

  static Future<UserGoals> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);

    if (goalsJson == null) {
      return UserGoals();
    }

    final goalsMap = json.decode(goalsJson);
    return UserGoals.fromMap(goalsMap);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  static Future<bool> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remindersKey) ?? true;
  }

  static Future<void> setReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, value);
  }

  static List<WellnessMetric> _generateInitialData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return WellnessMetric(
        date: date,
        steps: 5000 + (index * 1000),
        sleepHours: 6.5 + (index * 0.3),
        waterIntake: 2000 + (index * 200),
        heartRate: 65 + (index % 3),
        notes: index == 6 ? 'Feeling great today!' : null,
      );
    });
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
