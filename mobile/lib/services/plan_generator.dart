import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../screens/intake/intake_state.dart';

class PlanGenerator {
  Map<String, dynamic>? _workoutDb;
  Map<String, dynamic>? _injuryDb;

  Future<void> _loadWorkoutDb() async {
    if (_workoutDb != null) return;
    final raw = await rootBundle.loadString('assets/data/workout_plans_workout_only.json');
    _workoutDb = json.decode(raw) as Map<String, dynamic>;
  }

  Future<void> _loadInjuryDb() async {
    if (_injuryDb != null) return;
    final raw = await rootBundle.loadString('assets/data/injury_swap_table.json');
    _injuryDb = json.decode(raw) as Map<String, dynamic>;
  }

  // Public API (with status callback)
  Future<Map<String, dynamic>> generateWorkout(IntakeState intake, {void Function(String step)? onStep}) async {
    onStep?.call('Loading plans');
    await _loadWorkoutDb();
    final list = (_workoutDb?['plans'] ?? _workoutDb?['templates'] ?? []) as List? ?? [];

    onStep?.call('Scoring plans');
    final scored = <Map<String, dynamic>, int>{};
    for (final p in list) {
      if (p is! Map) continue;
      final plan = p.cast<String, dynamic>();
      int score = 0;
      // Strong match criteria
      if (_eq(plan['goal'], intake.goal)) score += 40;
      if (_eq(plan['experience_level'], intake.experience)) score += 30;
      if (_eq(plan['location'], intake.workoutLocation)) score += 20;
      // Optional / partial
      if (plan['gender'] == null || _eq(plan['gender'], intake.gender)) score += 5;
      if (plan['age_ranges'] is List && intake.ageRange != null && (plan['age_ranges'] as List).contains(intake.ageRange)) {
        score += 5;
      }
      scored[plan] = score;
    }

    Map<String, dynamic>? best;
    int bestScore = -1;
    scored.forEach((plan, score) {
      if (score > bestScore) {
        bestScore = score;
        best = plan;
      }
    });

    best ??= {
      'id': 'empty_plan',
      'days': <Map<String, dynamic>>[],
      'goal': intake.goal,
      'experience_level': intake.experience,
      'location': intake.workoutLocation
    };

    onStep?.call('Scaling volume');
    final scaled = _scaleVolume(best!, intake);

    onStep?.call('Applying injury substitutions');
    final withSubs = await _applyInjuries(scaled, intake);

    return withSubs;
  }

  Future<Map<String, dynamic>> generateNutrition(IntakeState intake, {void Function(String step)? onStep}) async {
    onStep?.call?.call('Calculating nutrition');
    // Age midpoint from range
    final ageMid = _ageMidpoint(intake.ageRange);
    final weight = intake.weightKg ?? 70.0;
    final height = intake.heightCm ?? 170.0;
    final gender = intake.gender ?? 'male';

    final bmr = _mifflinStJeor(gender: gender, weightKg: weight, heightCm: height, age: ageMid);
    // Activity assumption moderate
    final tdee = bmr * 1.45;

    double target = tdee;
    switch (intake.goal) {
      case 'fat_loss':
        target = tdee * 0.82;
        break;
      case 'muscle_gain':
        target = tdee * 1.12;
        break;
      default:
        target = tdee;
    }

    final protein = (weight * (intake.goal == 'muscle_gain' ? 2.0 : 1.7)).round();
    final fat = ((target * 0.25) / 9).round();
    final carbs = ((target - (protein * 4 + fat * 9)) / 4).round();

    return {
      'calories': target.round(),
      'protein_g': protein,
      'carbs_g': carbs,
      'fat_g': fat,
      'meals': [],
      'method': 'mifflin_st_jeor'
    };
  }

  // ---------- Helpers ----------

  bool _eq(dynamic a, dynamic b) => a != null && a == b;

  Map<String, dynamic> _scaleVolume(Map<String, dynamic> plan, IntakeState intake) {
    double mult = 1.0;
    switch (intake.experience) {
      case 'beginner': mult *= 0.9; break;
      case 'advanced': mult *= 1.15; break;
      default: break;
    }
    switch (intake.goal) {
      case 'fat_loss': mult *= 0.95; break;
      case 'muscle_gain': mult *= 1.10; break;
      default: break;
    }

    var days = (plan['days'] as List?)?.map((d) {
      if (d is! Map) return d;
      final blocks = (d['blocks'] as List?)?.map((b) {
        if (b is! Map) return b;
        final nb = Map<String, dynamic>.from(b);
        final sets = nb['sets'];
        final reps = nb['reps'];
        if (sets is int) nb['sets'] = (sets * mult).clamp(1, 12).round();
        if (reps is int) {
          nb['reps'] = (reps * mult).clamp(4, 25).round();
        } else if (reps is String && reps.contains('-')) {
          final parts = reps.split('-');
          if (parts.length == 2) {
            final lo = int.tryParse(parts[0]) ?? 0;
            final hi = int.tryParse(parts[1]) ?? lo;
            final newLo = (lo * mult).clamp(4, 25).round();
            final newHi = (hi * mult).clamp(6, 30).round();
            nb['reps'] = '$newLo-$newHi';
          }
        }
        return nb;
      }).toList();
      return {
        ...d,
        if (blocks != null) 'blocks': blocks,
      };
    }).toList();

    // Adjust number of days to requested daysPerWeek (2–6)
    final targetDays = (intake.daysPerWeek != null && intake.daysPerWeek! >= 2 && intake.daysPerWeek! <= 6)
        ? intake.daysPerWeek!
        : null;

    bool daysAdjusted = false;
    if (targetDays != null && days != null) {
      if (days.length > targetDays) {
        days = days.take(targetDays).toList();
        daysAdjusted = true;
      } else if (days.length < targetDays && days.isNotEmpty) {
        // Duplicate last day until reach target
        while (days.length < targetDays) {
          final clone = Map<String, dynamic>.from(days.last as Map);
          clone['day'] = 'Day ${days.length + 1}';
          days.add(clone);
        }
        daysAdjusted = true;
      }
    }

    return {
      ...plan,
      if (days != null) 'days': days,
      'volume_scaled': mult != 1.0,
      'volume_multiplier': mult,
      if (targetDays != null) 'target_days': targetDays,
      if (daysAdjusted) 'days_adjusted': true,
    };
  }

  Future<Map<String, dynamic>> _applyInjuries(Map<String, dynamic> plan, IntakeState intake) async {
    if (intake.injuries.isEmpty) return plan;
    await _loadInjuryDb();
    if (_injuryDb == null) return plan;

    final avoidKeywords = <String>{};
    final substitutions = <String, String>{};

    for (final inj in intake.injuries) {
      final data = _injuryDb?[inj];
      if (data is Map) {
        final avoids = (data['avoid_keywords'] as List?)?.cast<String>() ?? [];
        avoidKeywords.addAll(avoids.map((s) => s.toLowerCase()));
        final subs = data['substitutions'];
        if (subs is Map) {
          subs.forEach((k, v) {
            if (k is String && v is String) {
              substitutions[k.toLowerCase()] = v;
            }
          });
        }
      }
    }

    bool modified = false;
    final days = (plan['days'] as List?)?.map((d) {
      if (d is! Map) return d;
      final blocks = (d['blocks'] as List?)?.map((b) {
        if (b is! Map) return b;
        final name = (b['exercise'] ?? b['name'] ?? '').toString();
        final lower = name.toLowerCase();
        // Check avoid keywords
        if (avoidKeywords.any((k) => lower.contains(k))) {
          // Try substitution
          String? replacement;
            substitutions.forEach((k, v) {
              if (lower.contains(k)) {
                replacement = v;
              }
            });
          if (replacement != null) {
            modified = true;
            return {
              ...b,
              'exercise_original': name,
              'exercise': replacement,
              'modified_for_injury': true,
            };
          } else {
            modified = true;
            return {
              ...b,
              'skipped_due_to_injury': true,
            };
          }
        }
        return b;
      }).toList();
      return {
        ...d,
        if (blocks != null) 'blocks': blocks,
      };
    }).toList();

    return {
      ...plan,
      if (days != null) 'days': days,
      'injury_modifications': modified,
    };
  }

  int _ageMidpoint(String? range) {
    if (range == null) return 30;
    if (range.endsWith('+')) {
      final base = int.tryParse(range.replaceAll('+', '')) ?? 50;
      return base + 5;
    }
    final parts = range.split('-');
    if (parts.length == 2) {
      final a = int.tryParse(parts[0]) ?? 0;
      final b = int.tryParse(parts[1]) ?? a;
      return ((a + b) / 2).round();
    }
    return 30;
  }

  double _mifflinStJeor({required String gender, required double weightKg, required double heightCm, required int age}) {
    // Male: (10 * weight) + (6.25 * height) - (5 * age) + 5
    // Female: (10 * weight) + (6.25 * height) - (5 * age) - 161
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == 'female' ? base - 161 : base + 5;
  }
}