import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstIntakeData {
  final String? goal; // e.g., lose_weight, build_muscle, stay_fit
  final double? heightCm;
  final double? weightKg;
  const FirstIntakeData({this.goal, this.heightCm, this.weightKg});

  bool get isValid => (goal != null && goal!.isNotEmpty) && (heightCm != null && heightCm! > 0) && (weightKg != null && weightKg! > 0);

  Map<String, Object?> toJson() => {
        'goal': goal,
        'heightCm': heightCm,
        'weightKg': weightKg,
      };

  static FirstIntakeData fromJson(Map<String, Object?> m) => FirstIntakeData(
        goal: m['goal'] as String?,
        heightCm: (m['heightCm'] as num?)?.toDouble(),
        weightKg: (m['weightKg'] as num?)?.toDouble(),
      );
}

class SecondIntakeData {
  final String? experience; // beginner/intermediate/advanced
  final int? daysPerWeek; // 1..7
  final bool injuries;
  const SecondIntakeData({this.experience, this.daysPerWeek, this.injuries = false});

  bool get isValid => (experience != null && experience!.isNotEmpty) && (daysPerWeek != null && daysPerWeek! > 0);

  Map<String, Object?> toJson() => {
        'experience': experience,
        'daysPerWeek': daysPerWeek,
        'injuries': injuries,
      };

  static SecondIntakeData fromJson(Map<String, Object?> m) => SecondIntakeData(
        experience: m['experience'] as String?,
        daysPerWeek: (m['daysPerWeek'] as num?)?.toInt(),
        injuries: (m['injuries'] as bool?) ?? false,
      );
}

class IntakeState extends ChangeNotifier {
  FirstIntakeData first = const FirstIntakeData();
  SecondIntakeData second = const SecondIntakeData();
  String? gender; // male/female/other
  String? trainingLocation; // gym/home
  bool completed = false;
  bool loaded = false;

  Future<void> saveFirst(FirstIntakeData d) async {
    first = d;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('intake.first.goal', d.goal ?? '');
    await sp.setDouble('intake.first.height', d.heightCm ?? 0);
    await sp.setDouble('intake.first.weight', d.weightKg ?? 0);
    notifyListeners();
  }

  Future<void> saveSecond(SecondIntakeData d) async {
    second = d;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('intake.second.experience', d.experience ?? '');
    await sp.setInt('intake.second.days', d.daysPerWeek ?? 0);
    await sp.setBool('intake.second.injuries', d.injuries);
    notifyListeners();
  }

  bool get canComplete => first.isValid && second.isValid;

  Future<void> markCompleted() async {
    if (!canComplete) return;
    completed = true;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('intake.completed', true);
    notifyListeners();
  }

  Future<void> markQuickCompleted() async {
    completed = true;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('intake.completed', true);
    notifyListeners();
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final goal = sp.getString('intake.first.goal');
    final h = sp.getDouble('intake.first.height');
    final w = sp.getDouble('intake.first.weight');
    first = FirstIntakeData(
      goal: (goal != null && goal.isNotEmpty) ? goal : null,
      heightCm: (h != null && h > 0) ? h : null,
      weightKg: (w != null && w > 0) ? w : null,
    );
    final exp = sp.getString('intake.second.experience');
    final d = sp.getInt('intake.second.days');
    final inj = sp.getBool('intake.second.injuries') ?? false;
    second = SecondIntakeData(
      experience: (exp != null && exp.isNotEmpty) ? exp : null,
      daysPerWeek: (d != null && d > 0) ? d : null,
      injuries: inj,
    );
    completed = sp.getBool('intake.completed') ?? false;
    gender = sp.getString('intake.quick.gender');
    trainingLocation = sp.getString('intake.quick.location');
    loaded = true;
    notifyListeners();
  }

  Future<void> saveQuickGender(String g) async {
    gender = g;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('intake.quick.gender', g);
    notifyListeners();
  }

  Future<void> saveQuickLocation(String loc) async {
    trainingLocation = loc;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('intake.quick.location', loc);
    notifyListeners();
  }
}
