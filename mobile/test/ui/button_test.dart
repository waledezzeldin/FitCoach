import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/button.dart';
import '../test_utils.dart';

void main() {
  testWidgets('PrimaryButton taps call onPressed', (tester) async {
    var tapped = false;
    await tester.pumpThemed(PrimaryButton(label: 'Continue', onPressed: () => tapped = true));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('GhostButton renders text', (tester) async {
    await tester.pumpThemed(const GhostButton(label: 'Cancel'));
    expect(find.text('Cancel'), findsOneWidget);
  });
}
