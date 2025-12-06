import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'wellness_model.dart';

class WellnessData extends ChangeNotifier {
  List<WellnessMetric> _metrics = [];
  DailyInsights? _todayInsights;
  UserGoals _goals = UserGoals();
  bool _isLoading = true;
  bool _darkMode = false;
  bool _dailyReminders = true;

  WellnessData() {
    _loadData();
    _loadSettings();
  }

  List<WellnessMetric> get metrics => _metrics;
  DailyInsights? get insights => _todayInsights;
  UserGoals get goals => _goals;
  bool get isLoading => _isLoading;
  bool get darkMode => _darkMode;
  bool get dailyReminders => _dailyReminders;

  WellnessMetric get todayMetric {
    final today = DateTime.now();
    for (var metric in _metrics) {
      if (metric.date.year == today.year &&
          metric.date.month == today.month &&
          metric.date.day == today.day) {
        return metric;
      }
    }
    return WellnessMetric(
      date: today,
      steps: 0,
      sleepHours: 0,
      waterIntake: 0,
      heartRate: 0,
    );
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _metrics = await StorageService.loadMetrics();
      _goals = await StorageService.loadGoals();
      _calculateInsights();
    } catch (e) {
      print('Error loading data: $e');
      _metrics = [];
      _goals = UserGoals();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    _darkMode = await StorageService.getDarkMode();
    _dailyReminders = await StorageService.getReminders();
    notifyListeners();
  }

  Future<void> updateMetric(WellnessMetric metric) async {
    final index = _metrics.indexWhere((m) =>
        m.date.year == metric.date.year &&
        m.date.month == metric.date.month &&
        m.date.day == metric.date.day);

    if (index >= 0) {
      _metrics[index] = metric;
    } else {
      _metrics.add(metric);
    }

    await StorageService.saveMetric(metric);
    _calculateInsights();
    notifyListeners();
  }

  Future<void> updateTodayMetric({
    int? steps,
    double? sleep,
    int? water,
    int? heartRate,
    String? notes,
  }) async {
    final today = DateTime.now();
    final existingMetric = await StorageService.getMetricForDate(today);

    final updatedMetric = WellnessMetric(
      date: today,
      steps: steps ?? existingMetric?.steps ?? 0,
      sleepHours: sleep ?? existingMetric?.sleepHours ?? 0,
      waterIntake: water ?? existingMetric?.waterIntake ?? 0,
      heartRate: heartRate ?? existingMetric?.heartRate ?? 0,
      notes: notes ?? existingMetric?.notes,
    );

    await updateMetric(updatedMetric);
  }

  Future<void> updateGoals(UserGoals newGoals) async {
    _goals = newGoals;
    await StorageService.saveGoals(newGoals);
    _calculateInsights();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    await StorageService.setDarkMode(value);
    notifyListeners();
  }

  Future<void> toggleReminders(bool value) async {
    _dailyReminders = value;
    await StorageService.setReminders(value);
    notifyListeners();
  }

  void _calculateInsights() {
    final today = todayMetric;

    double stepsScore = (today.steps / _goals.dailySteps * 100).clamp(0, 100);
    double sleepScore =
        (today.sleepHours / _goals.dailySleep * 100).clamp(0, 100);
    double waterScore =
        (today.waterIntake / _goals.dailyWater * 100).clamp(0, 100);

    double heartScore = 100;
    if (today.heartRate > _goals.maxHeartRate) {
      heartScore = 100 - ((today.heartRate - _goals.maxHeartRate) * 10);
    }
    heartScore = heartScore.clamp(0, 100);

    double productivity = (stepsScore * 0.3) +
        (sleepScore * 0.3) +
        (waterScore * 0.2) +
        (heartScore * 0.2);

    String stress = 'Low';
    if (today.heartRate > _goals.maxHeartRate + 10) {
      stress = 'High';
    } else if (today.heartRate > _goals.maxHeartRate) {
      stress = 'Medium';
    }

    String sleepQuality = 'Poor';
    if (today.sleepHours >= 7.5) {
      sleepQuality = 'Excellent';
    } else if (today.sleepHours >= 7) {
      sleepQuality = 'Good';
    } else if (today.sleepHours >= 6) {
      sleepQuality = 'Fair';
    }

    String activity = 'Low';
    if (today.steps >= 10000) {
      activity = 'High';
    } else if (today.steps >= 5000) {
      activity = 'Moderate';
    }

    String suggestion =
        _generateSuggestion(today, stress, sleepQuality, activity);

    _todayInsights = DailyInsights(
      productivityScore: productivity,
      stressLevel: stress,
      sleepQuality: sleepQuality,
      topSuggestion: suggestion,
      hydrationScore: waterScore,
      activityLevel: activity,
    );
  }

  String _generateSuggestion(WellnessMetric today, String stress,
      String sleepQuality, String activity) {
    final suggestions = <String>[];

    if (today.steps < _goals.dailySteps * 0.7) {
      suggestions.add('Try a 20-min walk to reach step goal');
    }

    if (today.sleepHours < _goals.dailySleep * 0.8) {
      suggestions.add('Wind down 30 min earlier tonight');
    }

    if (today.waterIntake < _goals.dailyWater * 0.8) {
      suggestions.add('Drink water with each meal');
    }

    if (stress == 'High') {
      suggestions.add('Take 5 deep breaths - stress is high');
    }

    if (suggestions.isEmpty) {
      return 'Excellent! All goals met. Keep it up!';
    }

    return suggestions.join('. ');
  }

  Map<String, double> getWeeklyAverages() {
    if (_metrics.isEmpty) return {};

    final last7Days =
        _metrics.length > 7 ? _metrics.sublist(_metrics.length - 7) : _metrics;

    double stepsAvg = last7Days.map((m) => m.steps).reduce((a, b) => a + b) /
        last7Days.length;
    double sleepAvg =
        last7Days.map((m) => m.sleepHours).reduce((a, b) => a + b) /
            last7Days.length;
    double waterAvg =
        last7Days.map((m) => m.waterIntake).reduce((a, b) => a + b) /
            last7Days.length;
    double heartAvg =
        last7Days.map((m) => m.heartRate).reduce((a, b) => a + b) /
            last7Days.length;

    return {
      'steps': stepsAvg,
      'sleep': sleepAvg,
      'water': waterAvg,
      'heart': heartAvg,
    };
  }

  Future<void> addSampleData() async {
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      final date = now.subtract(Duration(days: 13 - i));
      final metric = WellnessMetric(
        date: date,
        steps: 4000 + (i * 500),
        sleepHours: 6.0 + (i * 0.2),
        waterIntake: 1800 + (i * 150),
        heartRate: 65 + (i % 4),
        notes: i % 3 == 0 ? 'Feeling good' : null,
      );
      await StorageService.saveMetric(metric);
    }
    await _loadData();
  }
}
