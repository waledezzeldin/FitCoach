import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/progress.dart';
import '../test_utils.dart';

void main() {
  testWidgets('FCLinearProgress shows', (tester) async {
    await tester.pumpThemed(const FCLinearProgress(value: 0.5));
    expect(find.byType(FCLinearProgress), findsOneWidget);
  });
}
