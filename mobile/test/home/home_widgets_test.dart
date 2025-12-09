import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/screens/home/home_widgets.dart';
import '../test_utils.dart';

void main() {
  testWidgets('QuickStatsRow renders labels and values', (tester) async {
    await tester.pumpThemed(QuickStatsRow(
      burnedTitle: 'Burned',
      consumedTitle: 'Consumed',
      burned: '1234',
      consumed: '1500/2000',
      burnedDelta: '+120 today',
    ));

    expect(find.text('Burned'), findsOneWidget);
    expect(find.text('Consumed'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);
    expect(find.text('1500/2000'), findsOneWidget);
    expect(find.text('+120 today'), findsOneWidget);
  });

  testWidgets('QuickActionsGrid fires onTap callback', (tester) async {
    String? tapped;
    await tester.pumpThemed(QuickActionsGrid(onTap: (k) => tapped = k));

    await tester.tap(find.text('Workouts'));
    await tester.pump();
    expect(tapped, equals('workouts'));
  });

  testWidgets('WeeklyProgress renders title', (tester) async {
    await tester.pumpThemed(WeeklyProgress(daily: const [0.1, 0.4, 0.8, 0.3, 0.7, 0.5, 0.9]));
    expect(find.text('Weekly Progress'), findsOneWidget);
  });
}
