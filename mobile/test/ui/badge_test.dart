import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/badge.dart';
import '../test_utils.dart';

void main() {
  testWidgets('FCBadge renders text', (tester) async {
    await tester.pumpThemed(const FCBadge(text: 'New'));
    expect(find.text('New'), findsOneWidget);
  });
}
