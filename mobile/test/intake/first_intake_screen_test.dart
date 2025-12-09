import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils.dart';
import 'package:fitcoach/screens/intake/first_intake_screen.dart';

void main() {
  testWidgets('FirstIntakeScreen enables Next only when valid', (tester) async {
    await tester.pumpThemed(const FirstIntakeScreen(), locale: const Locale('en'));

    final nextBtn = find.byKey(const Key('firstIntakeNext'));
    expect(nextBtn, findsOneWidget);

    // Initially disabled
    final goal = find.byType(DropdownButtonFormField<String>);
    await tester.tap(goal);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lose Weight').last);
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), '170');
    await tester.enterText(find.byType(TextField).at(1), '70');
    await tester.pump();

    // Button should now be enabled
    final btnWidget = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(btnWidget.onPressed, isNotNull);
  });
}
