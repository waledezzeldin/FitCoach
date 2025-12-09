import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach/workouts/session_controller.dart';

void main() {
  test('SessionController start/pause/reset updates elapsed', () async {
    final c = SessionController(tick: const Duration(milliseconds: 10));
    expect(c.elapsed.inMilliseconds, 0);
    expect(c.running, isFalse);

    c.start();
    expect(c.running, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 35));
    c.pause();
    final afterPause = c.elapsed;
    expect(afterPause.inMilliseconds >= 20, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 30));
    // paused, should not advance
    expect(c.elapsed, afterPause);

    c.reset();
    expect(c.elapsed.inMilliseconds, 0);
    expect(c.running, isFalse);
  });
}
