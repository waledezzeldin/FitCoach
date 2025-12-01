import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitcoach_plus/state/app_state.dart';
import 'package:fitcoach_plus/widgets/demo_mode_indicator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String?>{};

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'read':
          return storage[call.arguments['key'] as String? ?? ''];
        case 'write':
          storage[call.arguments['key'] as String? ?? ''] = call.arguments['value'] as String?;
          return true;
        case 'delete':
          storage.remove(call.arguments['key'] as String? ?? '');
          return true;
        case 'deleteAll':
          storage.clear();
          return true;
        default:
          return null;
      }
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('DemoModeIndicatorOverlay', () {
    late AppState appState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage.clear();
      appState = AppState(enableNetworkSync: false);
    });

    testWidgets('is hidden by default and appears when demoMode is enabled', (tester) async {
      await tester.pumpWidget(
        AppStateScope(
          notifier: appState,
          child: const MaterialApp(
            home: DemoModeIndicatorOverlay(
              child: Placeholder(),
            ),
          ),
        ),
      );

      expect(find.text('Demo mode active'), findsNothing);

      appState.setDemoMode(true);
      await tester.pumpAndSettle();

      expect(find.text('Demo mode active'), findsOneWidget);
      expect(find.text('Switch persona'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
    });
  });
}
