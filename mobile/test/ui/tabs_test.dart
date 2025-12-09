import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/tabs.dart';
import '../test_utils.dart';

void main() {
  testWidgets('PrimaryTabs renders tabs', (tester) async {
    late TabController ctrl;
    await tester.pumpThemed(
      Builder(builder: (context) {
        ctrl = TabController(length: 3, vsync: const TestVSync());
        return Column(children: [PrimaryTabs(tabs: const ['One', 'Two', 'Three'], controller: ctrl)]);
      }),
    );
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
  });
}

class TestVSync implements TickerProvider {
  const TestVSync();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
