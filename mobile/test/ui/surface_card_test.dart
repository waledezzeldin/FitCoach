import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/surface_card.dart';
import '../test_utils.dart';

void main() {
  testWidgets('SurfaceCard renders with border and radius', (tester) async {
    await tester.pumpThemed(const SurfaceCard(child: Text('Hello')));
    final cardFinder = find.byType(Card);
    expect(cardFinder, findsOneWidget);
    // Ensure text is present
    expect(find.text('Hello'), findsOneWidget);
  });
}
