import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/input.dart';
import '../test_utils.dart';

void main() {
  testWidgets('FitTextField accepts input (filled)', (tester) async {
    final c = TextEditingController();
    await tester.pumpThemed(FitTextField(controller: c, label: 'Phone', hint: 'Enter'));
    await tester.enterText(find.byType(TextField), '12345');
    expect(c.text, '12345');
  });

  testWidgets('FitTextField outlined renders without error', (tester) async {
    await tester.pumpThemed(const FitTextField(variant: FCInputVariant.outlined, label: 'Name'));
    expect(find.text('Name'), findsOneWidget);
  });
}
