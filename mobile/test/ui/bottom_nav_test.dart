import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/bottom_nav.dart';
import '../test_utils.dart';

void main() {
  testWidgets('FCBottomNav taps item', (tester) async {
    var tappedIndex = -1;
    await tester.pumpThemed(Scaffold(
      bottomNavigationBar: FCBottomNav(
        currentIndex: 0,
        onTap: (i) => tappedIndex = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Workouts'),
        ],
      ),
    ));
    await tester.tap(find.text('Workouts'));
    await tester.pump();
    expect(tappedIndex, 1);
  });
}
