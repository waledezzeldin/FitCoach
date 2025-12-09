import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/screens/store/store_list_screen.dart';
import 'package:fitcoach/store/store_state.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

void main() {
  group('Store widget tests', () {
    Widget buildStoreApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StoreState()),
        ],
        child: MaterialApp(
          home: const StoreListScreen(),
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: const [Locale('en'), Locale('ar')],
          locale: const Locale('en'),
        ),
      );
    }

    testWidgets('add to cart and checkout', (tester) async {
      await tester.pumpWidget(buildStoreApp());
      await tester.pumpAndSettle();

      // Tap first product to open details
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Tap Add to Cart
      final addBtn = find.widgetWithText(ElevatedButton, 'Add to Cart');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Go back to store list
      // Use Navigator.pop() instead of pageBack()
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Cart summary should show 1 item
      expect(find.textContaining('Cart: 1'), findsOneWidget);

      // Tap Checkout
      final checkoutBtn = find.widgetWithText(ElevatedButton, 'Checkout');
      expect(checkoutBtn, findsOneWidget);
      await tester.tap(checkoutBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Thank you for your purchase!'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();

      // Cart summary should disappear
      expect(find.textContaining('Cart:'), findsNothing);
    });
  });
}
