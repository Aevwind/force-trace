import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/domain/vbt/vision_frame_throttle.dart';

void main() {
  test(
    'bounds inference work for a high-rate camera without queuing frames',
    () {
      final throttle = VisionFrameThrottle();
      final accepted = <int>[];
      for (var i = 0; i < 120; i++) {
        final time = Duration(microseconds: (i * 1000000 / 60).round());
        if (throttle.accept(time)) accepted.add(time.inMicroseconds);
      }
      expect(accepted.length, inInclusiveRange(20, 30));
      for (var i = 1; i < accepted.length; i++) {
        expect(accepted[i] - accepted[i - 1], greaterThanOrEqualTo(66666));
      }
      // After a long inference there is no backlog or burst to catch up.
      expect(throttle.accept(const Duration(seconds: 10)), isTrue);
      expect(throttle.accept(const Duration(seconds: 10)), isFalse);
      throttle.reset();
      expect(throttle.accept(const Duration(seconds: 10)), isTrue);
    },
  );

  test('a 15 FPS camera is not accidentally throttled to half its rate', () {
    final throttle = VisionFrameThrottle();
    for (var i = 0; i < 30; i++) {
      expect(
        throttle.accept(Duration(microseconds: (i * 1000000 / 15).round())),
        isTrue,
      );
    }
  });
}
