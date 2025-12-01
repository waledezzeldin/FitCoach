import 'package:fitcoach_plus/localization/app_localizations.dart';
import 'package:fitcoach_plus/screens/workout/workout_session_screen.dart';
import 'package:fitcoach_plus/services/workout_service.dart';
import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'fc_workout_intro_seen': true,
    });
  });

  group('WorkoutSessionScreen', () {
    testWidgets('shows the overview for a provided workout payload',
        (tester) async {
      final l10n = AppLocalizations(const Locale('en'));
      final app = _buildAppState();
      final service = _TestWorkoutService();
      final workout = _sampleWorkout();

        await tester.pumpWidget(
          _wrapSession(app: app, workout: workout, service: service));
      await tester.pumpAndSettle();

      expect(find.text('Lower Body Blast'), findsOneWidget);
      expect(find.text(l10n.t('workouts.start')), findsWidgets);
    });

    testWidgets('enters the active exercise view when starting a workout',
        (tester) async {
      final l10n = AppLocalizations(const Locale('en'));
      final app = _buildAppState();
      final service = _TestWorkoutService();
      final workout = _sampleWorkout();

        await tester.pumpWidget(_wrapSession(
          app: app,
          workout: workout,
          service: service,
          autoStart: true,
        ));
        await tester.pumpAndSettle();

                expect(find.text(l10n.t('workouts.logSet')), findsWidgets);
    });
  });
}

Widget _wrapSession({
  required AppState app,
  required Map<String, dynamic> workout,
  required WorkoutService service,
  bool autoStart = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    initialRoute: '/session',
    onGenerateRoute: (settings) {
      if (settings.name == '/session') {
        return MaterialPageRoute(
          settings: RouteSettings(
              name: settings.name, arguments: {'workout': workout}),
          builder: (_) => AppStateScope(
            notifier: app,
            child: WorkoutSessionScreen(
              service: service,
              autoStartFirstExercise: autoStart,
            ),
          ),
        );
      }
      return null;
    },
  );
}

AppState _buildAppState() {
  final app = AppState(enableNetworkSync: false);
  app.user = {'id': 'user-42'};
  app.subscriptionType = 'premium';
  app.intakeProgress = app.intakeProgress.copyWith(skippedSecond: true);
  return app;
}

Map<String, dynamic> _sampleWorkout() {
  return {
    'id': 'w1',
    'name': 'Lower Body Blast',
    'duration': 45,
    'exercises': [
      {
        'id': 'ex1',
        'name': 'Back Squat',
        'muscleGroup': 'legs',
        'sets': [
          {'reps': 8, 'rest': 90},
        ],
      },
      {
        'id': 'ex2',
        'name': 'Romanian Deadlift',
        'muscleGroup': 'posterior chain',
        'sets': [
          {'reps': 10, 'rest': 60},
        ],
      },
    ],
  };
}

class _TestWorkoutService extends WorkoutService {
  @override
  Future<Map<String, dynamic>> startSession(String workoutId) async {
    return {'sessionId': 'session-$workoutId'};
  }

  @override
  Future<void> recordSet({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required int reps,
    required double weight,
    int? seconds,
  }) async {}

  @override
  Future<void> finishSession(String sessionId) async {}

  @override
  Future<List<Map<String, dynamic>>> injuryAlternatives({
    required String injuryArea,
    String? muscleGroup,
  }) async {
    return const [];
  }
}
