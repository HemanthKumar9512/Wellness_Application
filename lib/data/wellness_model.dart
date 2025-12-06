import 'dart:convert';

class WellnessMetric {
  final DateTime date;
  final int steps;
  final double sleepHours;
  final int waterIntake;
  final int heartRate;
  final String? notes;

  WellnessMetric({
    required this.date,
    required this.steps,
    required this.sleepHours,
    required this.waterIntake,
    required this.heartRate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'sleepHours': sleepHours,
      'waterIntake': waterIntake,
      'heartRate': heartRate,
      'notes': notes,
    };
  }

  factory WellnessMetric.fromMap(Map<String, dynamic> map) {
    return WellnessMetric(
      date: DateTime.parse(map['date']),
      steps: map['steps'] ?? 0,
      sleepHours: map['sleepHours'] ?? 0.0,
      waterIntake: map['waterIntake'] ?? 0,
      heartRate: map['heartRate'] ?? 0,
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WellnessMetric.fromJson(String source) =>
      WellnessMetric.fromMap(json.decode(source));
}

class DailyInsights {
  final double productivityScore;
  final String stressLevel;
  final String sleepQuality;
  final String topSuggestion;
  final double hydrationScore;
  final String activityLevel;

  DailyInsights({
    required this.productivityScore,
    required this.stressLevel,
    required this.sleepQuality,
    required this.topSuggestion,
    required this.hydrationScore,
    required this.activityLevel,
  });
}

class UserGoals {
  final int dailySteps;
  final double dailySleep;
  final int dailyWater;
  final int maxHeartRate;

  UserGoals({
    this.dailySteps = 8000,
    this.dailySleep = 8.0,
    this.dailyWater = 2500,
    this.maxHeartRate = 75,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailySteps': dailySteps,
      'dailySleep': dailySleep,
      'dailyWater': dailyWater,
      'maxHeartRate': maxHeartRate,
    };
  }

  factory UserGoals.fromMap(Map<String, dynamic> map) {
    return UserGoals(
      dailySteps: map['dailySteps'] ?? 8000,
      dailySleep: map['dailySleep'] ?? 8.0,
      dailyWater: map['dailyWater'] ?? 2500,
      maxHeartRate: map['maxHeartRate'] ?? 75,
    );
  }
}
