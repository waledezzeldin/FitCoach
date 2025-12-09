import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitcoach/app.dart';
import 'package:fitcoach/auth/auth_state.dart';
import 'package:fitcoach/screens/auth/login_screen.dart';
import 'package:fitcoach/screens/auth/signup_screen.dart';
import 'package:fitcoach/screens/intake/quick_start_step1.dart';
import 'package:fitcoach/screens/intake/quick_start_step2.dart';
import 'package:fitcoach/screens/intake/quick_start_step3.dart';
import 'package:fitcoach/screens/home/home_screen.dart';
import 'package:fitcoach/theme/fitcoach_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/subscription/subscription_state.dart';

void main() {
  testWidgets('Login navigates to home', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final routes = <String, WidgetBuilder>{
      '/': (_) => const HomeScreen(),
      '/home': (_) => const HomeScreen(),
      '/login': (_) => const LoginScreen(),
      '/signup': (_) => const SignUpScreen(),
      '/quickstart/1': (_) => const QuickStartStep1(),
      '/quickstart/2': (_) => const QuickStartStep2(),
      '/quickstart/3': (_) => const QuickStartStep3(),
    };

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthState()..load()),
          ChangeNotifierProvider(create: (_) => SubscriptionState()..load()),
        ],
        child: MaterialApp(
          theme: FitCoachTheme.light(),
          darkTheme: FitCoachTheme.dark(),
          initialRoute: '/login',
          routes: routes,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        ),
      ),
    );
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byKey(const Key('loginAppBar')), findsOneWidget);
    // Switch to email login mode
    await tester.tap(find.text('Continue with Email'));
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byKey(const Key('loginSubmit')));
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    expect(find.byType(QuickStartStep1), findsOneWidget);
  });

  testWidgets('Sign up navigates to home', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final routes = <String, WidgetBuilder>{
      '/': (_) => const HomeScreen(),
      '/home': (_) => const HomeScreen(),
      '/login': (_) => const LoginScreen(),
      '/signup': (_) => const SignUpScreen(),
      '/quickstart/1': (_) => const QuickStartStep1(),
      '/quickstart/2': (_) => const QuickStartStep2(),
      '/quickstart/3': (_) => const QuickStartStep3(),
    };

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthState()..load()),
          ChangeNotifierProvider(create: (_) => SubscriptionState()..load()),
        ],
        child: MaterialApp(
          theme: FitCoachTheme.light(),
          darkTheme: FitCoachTheme.dark(),
          initialRoute: '/signup',
          routes: routes,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('signupAppBar')), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'newuser@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.byKey(const Key('signupSubmit')));
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }

    expect(find.byType(QuickStartStep1), findsOneWidget);
  });
}
