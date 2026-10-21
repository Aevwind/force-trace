import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/domain/vbt/rep_state_machine.dart';
import 'package:force_trace/domain/vbt/pose_models.dart';

const _dtMs = 33;
const _k = 0.00375;

double _ease(double t) =>
    t < 0.5 ? 4 * t * t * t : (1 - math.pow(-2 * t + 2, 3) / 2).toDouble();

double _yAt(int ms, double travel) {
  if (ms < 600) return 300;
  if (ms < 2100) {
    final p = (ms - 600) / 1500;
    return 300 + travel * _ease(p);
  }
  if (ms < 2400) return 300 + travel;
  if (ms < 3500) {
    final p = (ms - 2400) / 1100;
    return 300 + travel * (1 - _ease(p));
  }
  return 300;
}

({RepAttempt? attempt, Set<RepPhase> phases}) _replay({
  required double travelPx,
  double minRomCm = 35,
}) {
  final machine = RepStateMachine(minRomCm: minRomCm);
  final phases = <RepPhase>{};
  RepAttempt? completion;
  var previousY = _yAt(0, travelPx);
  for (var ms = 0; ms <= 4200; ms += _dtMs) {
    final y = _yAt(ms, travelPx);
    final dy = y - previousY;
    final velocity = -dy * _k / (_dtMs / 1000);
    final attempt = machine.update(
      timestampMs: ms,
      barY: y,
      metersPerPixel: _k,
      verticalVelocity: velocity,
      speed: velocity.abs(),
      hipAngle: 90,
      kneeAngle: 90,
      elbowAngle: 90,
    );
    phases.add(machine.phase);
    if (attempt != null) completion = attempt;
    previousY = y;
  }
  return (attempt: completion, phases: phases);
}

void main() {
  group('RepStateMachine', () {
    test('detects a full squat rep with plausible ROM and velocity', () {
      final result = _replay(travelPx: 160);
      final attempt = result.attempt;
      expect(attempt, isNotNull);
      expect(attempt!.valid, isTrue);
      expect(attempt.romCm, closeTo(60, 2));
      expect(attempt.meanVelocity, greaterThan(0.3));
      expect(attempt.peakVelocity, greaterThan(attempt.meanVelocity));
      expect(attempt.eccentricMs, greaterThan(1000));
      expect(attempt.concentricMs, greaterThan(800));
      expect(attempt.durationMs, greaterThan(2000));
      expect(result.phases, contains(RepPhase.eccentric));
      expect(result.phases, contains(RepPhase.concentric));
      expect(result.phases, contains(RepPhase.completed));
    });

    test('rejects a shallow rep below the ROM threshold', () {
      final result = _replay(travelPx: 70);
      expect(result.attempt, isNotNull);
      expect(result.attempt!.valid, isFalse);
      expect(result.attempt!.romCm, lessThan(35));
    });

    test('does not count a rep that only moves upward', () {
      final machine = RepStateMachine(minRomCm: 20);
      RepAttempt? attempt;
      for (var ms = 0; ms < 2000; ms += _dtMs) {
        final y = 400 - ms * 0.1;
        attempt = machine.update(
          timestampMs: ms,
          barY: y,
          metersPerPixel: _k,
          verticalVelocity: 0.3,
          speed: 0.3,
          hipAngle: 120,
          kneeAngle: 120,
          elbowAngle: 120,
        );
      }
      expect(attempt, isNull);
      expect(machine.repIndex, 0);
    });

    test('starts a second rep after the completed hold', () {
      final machine = RepStateMachine(minRomCm: 35);
      // Feed two concatenated reps with 500 ms of idle between them.
      RepAttempt? last;
      var previousY = 300.0;
      for (var ms = 0; ms <= 9000; ms += _dtMs) {
        final local = ms % 4300;
        final y = _yAt(local, 160);
        final dy = y - previousY;
        final velocity = -dy * _k / (_dtMs / 1000);
        final attempt = machine.update(
          timestampMs: ms,
          barY: y,
          metersPerPixel: _k,
          verticalVelocity: velocity,
          speed: velocity.abs(),
          hipAngle: 90,
          kneeAngle: 90,
          elbowAngle: 90,
        );
        if (attempt != null) last = attempt;
        previousY = y;
      }
      expect(machine.repIndex, greaterThanOrEqualTo(2));
      expect(last?.index, greaterThanOrEqualTo(1));
    });
  });
}
