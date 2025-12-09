import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/app.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:fitcoach/subscription/subscription_state.dart';
import 'package:fitcoach/screens/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Freemium shows Tap to Upgrade badge on Nutrition tile', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'subscription.tier': 'freemium'});
    await tester.pumpWidget(FitCoachApp());
    await tester.pump();

    // App will likely route to language; directly render HomeScreen to check badge
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionState()..load()),
      ],
      child: MaterialApp(
        home: const HomeScreen(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        theme: FitCoachTheme.light(),
      ),
    ));
    await tester.pump();

    // Title localized to 'Nutrition' still in EN; if localized changes, consider using a Key.
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('👆 Tap to Upgrade'), findsOneWidget);
  });
}
