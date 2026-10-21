import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/domain/vbt/pose_models.dart';
import 'package:force_trace/domain/vbt/vision_pose_mapper.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

Pose _pose({
  double left = 0.95,
  double right = 0.9,
  bool hideLeftWrist = false,
}) {
  final points = <PoseLandmarkType, PoseLandmark>{};
  for (final type in PoseLandmarkType.values) {
    final isLeft = type.name.startsWith('left');
    points[type] = PoseLandmark(
      type: type,
      x: isLeft ? 120 : 360,
      y: 240,
      z: 0,
      likelihood: hideLeftWrist && type == PoseLandmarkType.leftWrist
          ? 0.1
          : (isLeft ? left : right),
    );
  }
  return Pose(landmarks: points);
}

void main() {
  test('score fluctuations preserve anatomical sides and reference point', () {
    final mapper = VisionPoseMapper(pattern: MotionPattern.bench);
    VisionFrame map(Pose pose) => mapper.map(
      pose,
      imageSize: const Size(480, 640),
      mirror: false,
      timestampMs: 100,
    );
    final first = map(_pose());
    final second = map(_pose(left: 0.8, right: 0.99));
    expect(first.frame.hasPose, isTrue);
    expect(second.frame.landmarks, first.frame.landmarks);
    expect(second.frame.secondaryLandmarks, first.frame.secondaryLandmarks);
    expect(second.frame.trackedPoint, first.frame.trackedPoint);
    expect(second.frame.trackingId, first.frame.trackingId);
    // Occlusion cannot change a wrist reference into a shoulder or midpoint.
    expect(map(_pose(hideLeftWrist: true)).frame.hasPose, isFalse);
    mapper.reset();
    final reacquired = map(_pose(left: 0.8, right: 0.99));
    expect(reacquired.frame.trackedPoint.dx, 0.75);
    expect(reacquired.frame.trackingId, isNot(first.frame.trackingId));
  });

  test(
    'mirrors pixel coordinates consistently, including pixels near zero',
    () {
      final pose = _pose();
      pose.landmarks[PoseLandmarkType.leftShoulder] = PoseLandmark(
        type: PoseLandmarkType.leftShoulder,
        x: 0.5,
        y: 0.5,
        z: 0,
        likelihood: 1,
      );
      final frame = VisionPoseMapper(pattern: MotionPattern.squat)
          .map(
            pose,
            imageSize: const Size(480, 640),
            mirror: true,
            timestampMs: 123,
          )
          .frame;
      expect(frame.timestampMs, 123);
      expect(frame.trackedPoint.dx, closeTo(1 - 0.5 / 480, 1e-9));
      expect(frame.trackedPoint.dy, closeTo(0.5 / 640, 1e-9));
    },
  );
}
