import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

Widget _appWithLocale(Locale locale, Widget child) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  testWidgets('English locale is LTR and shows English strings', (tester) async {
    await tester.pumpWidget(_appWithLocale(const Locale('en'), Builder(
      builder: (context) {
        final t = AppLocalizations.of(context);
        return Text('${t.titleWelcome}-${Directionality.of(context)}');
      },
    )));
    await tester.pump();
    expect(find.textContaining('Welcome'), findsOneWidget);
    expect(find.textContaining('TextDirection.ltr'), findsOneWidget);
  });

  testWidgets('Arabic locale is RTL and shows Arabic strings', (tester) async {
    await tester.pumpWidget(_appWithLocale(const Locale('ar'), Builder(
      builder: (context) {
        final t = AppLocalizations.of(context);
        return Text('${t.titleWelcome}-${Directionality.of(context)}');
      },
    )));
    await tester.pump();
    expect(find.textContaining('مرحبًا'), findsOneWidget);
    expect(find.textContaining('TextDirection.rtl'), findsOneWidget);
  });
}
