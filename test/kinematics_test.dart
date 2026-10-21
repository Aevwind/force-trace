import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/domain/vbt/angles.dart';
import 'package:force_trace/domain/vbt/one_euro_filter.dart';

void main() {
  group('joint angles', () {
    test('right angle', () {
      expect(
        jointAngle(const Offset(10, 0), Offset.zero, const Offset(0, 10)),
        closeTo(90, 0.001),
      );
    });

    test('straight line is 180 degrees', () {
      expect(
        hipAngle(const Offset(0, -10), Offset.zero, const Offset(0, 10)),
        closeTo(180, 0.001),
      );
    });

    test('knee angle uses hip-knee-ankle', () {
      expect(
        kneeAngle(const Offset(-10, 0), Offset.zero, const Offset(0, 10)),
        closeTo(90, 0.001),
      );
    });

    test('formatAngle rounds', () {
      expect(formatAngle(42.4), '42°');
      expect(formatAngle(42.6), '43°');
    });
  });

  group('OneEuroFilter', () {
    test('converges to a static signal', () {
      final filter = OneEuroFilter(minCutoff: 1.6, beta: 1.2);
      for (var i = 0; i < 120; i++) {
        filter.filter(0.42, i / 30);
      }
      expect(filter.value, closeTo(0.42, 0.01));
    });

    test('reduces jitter while preserving fast movement', () {
      final filter = OneEuroFilter(minCutoff: 1.6, beta: 1.2);
      final samples = <double>[];
      for (var i = 0; i < 90; i++) {
        final noise = i.isEven ? 0.01 : -0.01;
        samples.add(filter.filter(0.5 + noise, i / 30));
      }
      final tail = samples.sublist(30);
      final average = tail.reduce((a, b) => a + b) / tail.length;
      final variance = tail
          .map((value) => (value - average).abs())
          .reduce((a, b) => a > b ? a : b);
      expect(average, closeTo(0.5, 0.01));
      expect(variance, lessThan(0.02));
    });

    test('reacts quickly to a step change', () {
      final filter = OneEuroFilter(minCutoff: 1.8, beta: 2.0);
      var value = 0.0;
      for (var i = 0; i < 30; i++) {
        value = filter.filter(0, i / 30);
      }
      expect(value, closeTo(0, 0.01));
      for (var i = 30; i < 36; i++) {
        value = filter.filter(1, i / 30);
      }
      expect(value, greaterThan(0.25));
    });

    test('reset clears state', () {
      final filter = OneEuroFilter();
      for (var i = 0; i < 10; i++) {
        filter.filter(1, i / 30);
      }
      filter.reset();
      expect(filter.value, 0);
      expect(filter.filter(0.3, 0), 0.3);
    });
  });

  group('FpsCounter', () {
    test('computes a moving average', () {
      final counter = FpsCounter(window: 3);
      expect(counter.add(1 / 30), closeTo(30, 0.001));
      expect(counter.add(1 / 60), closeTo(40, 0.001));
      expect(counter.add(1 / 30), closeTo(36, 0.001));
    });
  });
}
