import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/coach/coach_state.dart';
import 'package:fitcoach/screens/coach/coach_screen.dart';
import '../test_utils.dart';

// Use shared pump utility that injects providers and localization

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Freemium shows upgrade prompt for attachments', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'subscription.tier': 'freemium'});
    await tester.pumpThemed(const CoachScreen());
    await tester.pumpAndSettle();

    expect(find.text('Attach File'), findsOneWidget);
    expect(find.text('Attachments are available for Premium members only'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets('Premium enables attachments', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'subscription.tier': 'premium'});
    await tester.pumpThemed(const CoachScreen());
    await tester.pumpAndSettle();

    expect(find.text('Attach File'), findsOneWidget);
    expect(find.textContaining('Attachments enabled'), findsOneWidget);
  });
}
