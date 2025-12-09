import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/button.dart';
import 'package:fitcoach/ui/surface_card.dart';
import '../test_utils.dart';

void main() {
  group('UI Goldens (baseline)', () {
    testWidgets('PrimaryButton light', (tester) async {
      await tester.binding.setSurfaceSize(const Size(200, 80));
      await tester.pumpThemed(const PrimaryButton(label: 'Continue'));
      await expectLater(find.byType(PrimaryButton), matchesGoldenFile('goldens/primary_button.light.png'));
    }, skip: true);

    testWidgets('SurfaceCard light', (tester) async {
      await tester.binding.setSurfaceSize(const Size(240, 120));
      await tester.pumpThemed(const SurfaceCard(child: Text('Hello')));
      await expectLater(find.byType(SurfaceCard), matchesGoldenFile('goldens/surface_card.light.png'));
    }, skip: true);
  });
}
