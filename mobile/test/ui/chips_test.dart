import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/ui/chips.dart';
import '../test_utils.dart';

void main() {
  testWidgets('FCChoiceChip toggles selection', (tester) async {
    var selected = false;
    await tester.pumpThemed(FCChoiceChip(label: 'A', selected: selected, onSelected: (v) => selected = v));
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(selected, isTrue);
  });
}
