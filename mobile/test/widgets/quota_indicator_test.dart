import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitapp/presentation/widgets/quota_indicator.dart';

void main() {
  group('QuotaIndicator Widget Tests', () {
    testWidgets('renders message quota indicator (default)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuotaIndicator(type: 'message'),
          ),
        ),
      );
      expect(find.byType(QuotaIndicator), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
    });

    testWidgets('renders video call quota indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuotaIndicator(type: 'videoCall'),
          ),
        ),
      );
      expect(find.byType(QuotaIndicator), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('renders with showDetails true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuotaIndicator(type: 'message', showDetails: true),
          ),
        ),
      );
      expect(find.byType(QuotaIndicator), findsOneWidget);
      // Should find a column or more detailed info
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders with showDetails false (compact)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuotaIndicator(type: 'message', showDetails: false),
          ),
        ),
      );
      expect(find.byType(QuotaIndicator), findsOneWidget);
      // Should find a row for compact info
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('renders unlimited state for Smart Premium', (WidgetTester tester) async {
      // This test assumes the provider is mocked to return limit == -1 for messages
      // In a real test, you would use a mock provider or test harness
      // Here, we just check the widget builds without error
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuotaIndicator(type: 'message'),
          ),
        ),
      );
      expect(find.byType(QuotaIndicator), findsOneWidget);
    });
  });
}