import 'package:fitcoach_plus/models/quota_models.dart';
import 'package:fitcoach_plus/screens/nutrition/nutrition_preferences_flow.dart';
import 'package:fitcoach_plus/widgets/nutrition_expiry_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NutritionExpiryBanner prompts upgrade when locked', (tester) async {
    var upgradeTapped = false;
    final snapshot = NutritionAccessSnapshot(
      plan: NutritionPlanMeta(
        generatedAt: DateTime(2024, 1, 1),
        expiresAt: DateTime(2024, 1, 3),
        locked: true,
      ),
      status: const NutritionExpiryStatus(
        isExpired: true,
        isLocked: true,
        canAccess: false,
        daysRemaining: 0,
        hoursRemaining: 0,
        expiryMessage: 'Plan expired',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NutritionExpiryBanner(
            snapshot: snapshot,
            tier: SubscriptionTier.freemium,
            onUpgrade: () => upgradeTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Upgrade to unlock'), findsOneWidget);
    await tester.tap(find.text('Upgrade to unlock'));
    await tester.pump();
    expect(upgradeTapped, isTrue);
  });

  testWidgets('NutritionExpiryBanner shows regenerate action for freemium access', (tester) async {
    var regenerateTapped = false;
    final snapshot = NutritionAccessSnapshot(
      plan: NutritionPlanMeta(
        generatedAt: DateTime(2024, 2, 1),
        expiresAt: DateTime(2024, 2, 6),
        locked: false,
      ),
      status: const NutritionExpiryStatus(
        isExpired: false,
        isLocked: false,
        canAccess: true,
        daysRemaining: 5,
        hoursRemaining: null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NutritionExpiryBanner(
            snapshot: snapshot,
            tier: SubscriptionTier.freemium,
            onRegenerate: () => regenerateTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Regenerate'), findsOneWidget);
    await tester.tap(find.text('Regenerate'));
    await tester.pump();
    expect(regenerateTapped, isTrue);
  });

  testWidgets('NutritionPreferencesFlow returns updated values', (tester) async {
    NutritionPreferences? captured;

    await tester.pumpWidget(
      MaterialApp(
        home: _FlowHarness(
          onResult: (value) => captured = value,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Chicken').first);
    await tester.tap(find.text('Eggs').last);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filling'));
    await tester.tap(find.text('Prep-ahead'));
    await tester.tap(find.text('Low-carb'));
    await tester.tap(find.text('Hot'));
    await tester.ensureVisible(find.text('Egyptian'));
    await tester.tap(find.text('Egyptian'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Spicy foods'));
    await tester.tap(find.text('Spicy foods'));
    await tester.enterText(find.byType(TextField), 'Extra spice');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Complete Setup'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.proteinSources, contains('chicken'));
    expect(captured!.proteinAllergies, contains('eggs'));
    expect(captured!.dinnerPreferences?['portionSize'], 'filling');
    expect(captured!.dinnerPreferences?['prepSpeed'], 'prep_ahead');
    expect(captured!.dinnerPreferences?['carbLevel'], 'low_carb');
    expect(captured!.dinnerPreferences?['temperature'], 'hot');
    expect(captured!.dinnerPreferences?['cuisines'], contains('egyptian'));
    expect(captured!.dinnerPreferences?['avoid'], contains('spicy'));
    expect(captured!.additionalNotes, 'Extra spice');
  });
}

class _FlowHarness extends StatefulWidget {
  const _FlowHarness({required this.onResult});

  final ValueChanged<NutritionPreferences?> onResult;

  @override
  State<_FlowHarness> createState() => _FlowHarnessState();
}

class _FlowHarnessState extends State<_FlowHarness> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await Navigator.of(context).push<NutritionPreferences>(
        MaterialPageRoute(
          builder: (_) => NutritionPreferencesFlow(initial: NutritionPreferences.empty()),
        ),
      );
      widget.onResult(result);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
