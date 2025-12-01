class FirstIntakeData {
  FirstIntakeData({
    required this.gender,
    required this.mainGoal,
    required this.workoutLocation,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  final String gender;
  final String mainGoal;
  final String workoutLocation;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'mainGoal': mainGoal,
        'workoutLocation': workoutLocation,
        'completedAt': completedAt.toIso8601String(),
      };

  factory FirstIntakeData.fromJson(Map<String, dynamic> json) => FirstIntakeData(
        gender: json['gender']?.toString() ?? 'male',
        mainGoal: json['mainGoal']?.toString() ?? 'general_fitness',
        workoutLocation: json['workoutLocation']?.toString() ?? 'home',
        completedAt: _parseDate(json['completedAt']),
      );
}

class SecondIntakeData {
  SecondIntakeData({
    required this.age,
    required this.weight,
    required this.height,
    required this.experienceLevel,
    required this.workoutFrequency,
    required this.injuries,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  final int age;
  final double weight;
  final double height;
  final String experienceLevel;
  final int workoutFrequency;
  final List<String> injuries;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        'age': age,
        'weight': weight,
        'height': height,
        'experienceLevel': experienceLevel,
        'workoutFrequency': workoutFrequency,
        'injuries': injuries,
        'completedAt': completedAt.toIso8601String(),
      };

  factory SecondIntakeData.fromJson(Map<String, dynamic> json) => SecondIntakeData(
        age: _asInt(json['age']) ?? 0,
        weight: _asDouble(json['weight']) ?? 0,
        height: _asDouble(json['height']) ?? 0,
        experienceLevel: json['experienceLevel']?.toString() ?? 'beginner',
        workoutFrequency: _asInt(json['workoutFrequency']) ?? 2,
        injuries: (json['injuries'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        completedAt: _parseDate(json['completedAt']),
      );
}

class IntakeProgress {
  const IntakeProgress({
    this.first,
    this.second,
    this.skippedSecond = false,
  });

  final FirstIntakeData? first;
  final SecondIntakeData? second;
  final bool skippedSecond;

  bool get isFirstComplete => first != null;
  bool get isSecondComplete => second != null;
  bool get requiresSecondStage => isFirstComplete && !isSecondComplete && !skippedSecond;

  IntakeProgress copyWith({
    FirstIntakeData? first,
    SecondIntakeData? second,
    bool? skippedSecond,
  }) {
    return IntakeProgress(
      first: first ?? this.first,
      second: second ?? this.second,
      skippedSecond: skippedSecond ?? this.skippedSecond,
    );
  }

  Map<String, dynamic> toJson() => {
        if (first != null) 'first': first!.toJson(),
        if (second != null) 'second': second!.toJson(),
        'skippedSecond': skippedSecond,
      };

  factory IntakeProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const IntakeProgress();
    return IntakeProgress(
      first: json['first'] is Map<String, dynamic>
          ? FirstIntakeData.fromJson(json['first'] as Map<String, dynamic>)
          : null,
      second: json['second'] is Map<String, dynamic>
          ? SecondIntakeData.fromJson(json['second'] as Map<String, dynamic>)
          : null,
      skippedSecond: json['skippedSecond'] == true,
    );
  }
}

DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  return DateTime.now();
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
