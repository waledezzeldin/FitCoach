import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// go_router not needed in this simplified test
import 'package:fitcoach/screens/workouts/workout_detail_screen.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

void main() {
  testWidgets('Workout detail renders', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    await tester.pumpWidget(MaterialApp(
      theme: FitCoachTheme.light(),
      darkTheme: FitCoachTheme.dark(),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const WorkoutDetailScreen(id: 'w1'),
    ));
    await tester.pump();
    expect(find.textContaining('Workout'), findsOneWidget);
    expect(find.textContaining('Start'), findsOneWidget);
  });
}
