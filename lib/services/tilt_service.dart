import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

class TiltService {
  /// Emits the phone's pitch in degrees. Falls back to 0 (level) when the
  /// platform has no accelerometer, which is common in desktop web browsers.
  Stream<double> tiltStream() async* {
    try {
      await for (final event in accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      )) {
        final pitch =
            math.atan2(
              event.y,
              math.sqrt(event.x * event.x + event.z * event.z),
            ) *
            180 /
            math.pi;
        // ±90°: 0 is flat/landscape, ±90 is upright portrait. The calibration
        // UI accepts both mounts; do not clamp to ±60 as that hides a true
        // portrait orientation.
        yield pitch.clamp(-90.0, 90.0);
      }
    } catch (_) {
      yield 0;
    }
  }
}
