import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../test_utils.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/screens/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Freemium shows Arabic upgrade badge on Nutrition tile', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'subscription.tier': 'freemium'});
    await tester.pumpThemed(const Directionality(textDirection: TextDirection.rtl, child: HomeScreen()), locale: const Locale('ar'));
    await tester.pump();

    // In Arabic, title may remain English or be localized; assert badge only.
    expect(find.text('👆 اضغط للترقية'), findsOneWidget);
  });
}
