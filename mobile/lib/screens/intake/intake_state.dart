import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class IntakeState {
  int? ageYears;
  String? ageRange;
  String? gender;
  String? workoutLocation;
  String? goal;
  String? experience;
  int? daysPerWeek;
  double? weightKg;
  double? heightCm;
  final Set<String> injuries = {};

  Map<String, dynamic>? injuryTable;
  Map<String, dynamic>? templates;

  void setAge(int? age) {
    ageYears = age;
    if (age == null) {
      ageRange = null;
      return;
    }
    if (age <= 17) {
      ageRange = '10-17';
    } else if (age <= 25) {
      ageRange = '18-25';
    } else if (age <= 35) {
      ageRange = '26-35';
    } else if (age <= 50) {
      ageRange = '36-50';
    } else {
      ageRange = '51+';
    }
  }

  Future<void> loadInjuryTable() async {
    if (injuryTable != null) return;
    try {
      final raw = await rootBundle.loadString('assets/data/injury_swap_table.json');
      injuryTable = json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      injuryTable = {};
    }
  }

  Future<void> loadTemplates() async {
    if (templates != null) return;
    try {
      final raw = await rootBundle.loadString('assets/data/workout_plans_workout_only.json');
      templates = json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      templates = {};
    }
  }

  Map<String, dynamic> toMap() => {
    'age_years': ageYears,
    'age_range': ageRange,
    'gender': gender,
    'location': workoutLocation,
    'goal': goal,
    'experience_level': experience,
    'days_per_week': daysPerWeek,
    'weight_kg': weightKg,
    'height_cm': heightCm,
    'injuries': injuries.toList(),
  };
}