import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_models.dart';

/// Maps ML Kit pixels to stable anatomical sides in normalized coordinates.
class VisionPoseMapper {
  VisionPoseMapper({required this.pattern});

  final MotionPattern pattern;
  bool? _useLeft;
  int _trackingId = 0;

  void reset() {
    _useLeft = null;
    _trackingId++;
  }

  VisionFrame map(
    Pose pose, {
    required Size imageSize,
    required bool mirror,
    required double timestampMs,
  }) {
    Offset? point(PoseLandmarkType type, {double minLikelihood = 0.5}) {
      final landmark = pose.landmarks[type];
      if (landmark == null ||
          !landmark.x.isFinite ||
          !landmark.y.isFinite ||
          !landmark.likelihood.isFinite ||
          landmark.likelihood < minLikelihood) {
        return null;
      }
      // ML Kit coordinates are always image pixels, including points outside
      // the image. Normalize every point with the same transform.
      var x = landmark.x / imageSize.width;
      var y = landmark.y / imageSize.height;
      x = x.clamp(0.0, 1.0);
      y = y.clamp(0.0, 1.0);
      return Offset(mirror ? 1 - x : x, y);
    }

    double score(List<PoseLandmarkType> types) {
      var sum = 0.0;
      for (final type in types) {
        final landmark = pose.landmarks[type];
        if (landmark == null || !landmark.likelihood.isFinite) continue;
        sum += landmark.likelihood.clamp(0.0, 1.0);
      }
      return sum / types.length;
    }

    final leftScore = score(const [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    ]);
    final rightScore = score(const [
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    ]);

    Offset? midpoint(PoseLandmarkType left, PoseLandmarkType right) {
      final a = point(left);
      final b = point(right);
      if (a == null) return b;
      if (b == null) return a;
      return Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    }

    final head =
        point(PoseLandmarkType.nose) ??
        midpoint(PoseLandmarkType.leftEar, PoseLandmarkType.rightEar);

    Map<LandmarkId, Offset> sideMap(bool left) {
      final map = <LandmarkId, Offset>{};
      void put(LandmarkId id, Offset? value) {
        if (value != null) map[id] = value;
      }

      put(LandmarkId.head, head);
      put(
        LandmarkId.shoulder,
        point(
          left ? PoseLandmarkType.leftShoulder : PoseLandmarkType.rightShoulder,
        ),
      );
      put(
        LandmarkId.elbow,
        point(left ? PoseLandmarkType.leftElbow : PoseLandmarkType.rightElbow),
      );
      put(
        LandmarkId.wrist,
        point(left ? PoseLandmarkType.leftWrist : PoseLandmarkType.rightWrist),
      );
      put(
        LandmarkId.hip,
        point(left ? PoseLandmarkType.leftHip : PoseLandmarkType.rightHip),
      );
      put(
        LandmarkId.knee,
        point(left ? PoseLandmarkType.leftKnee : PoseLandmarkType.rightKnee),
      );
      put(
        LandmarkId.ankle,
        point(left ? PoseLandmarkType.leftAnkle : PoseLandmarkType.rightAnkle),
      );
      put(
        LandmarkId.toe,
        point(
              left
                  ? PoseLandmarkType.leftFootIndex
                  : PoseLandmarkType.rightFootIndex,
            ) ??
            map[LandmarkId.ankle],
      );
      return map;
    }

    final left = sideMap(true);
    final right = sideMap(false);
    final referenceId = switch (pattern) {
      MotionPattern.squat || MotionPattern.pushup => LandmarkId.shoulder,
      MotionPattern.bench ||
      MotionPattern.press ||
      MotionPattern.hinge ||
      MotionPattern.curl => LandmarkId.wrist,
      MotionPattern.pullup => LandmarkId.hip,
    };
    bool complete(Map<LandmarkId, Offset> side) => [
      LandmarkId.shoulder,
      LandmarkId.hip,
      LandmarkId.knee,
      LandmarkId.ankle,
      referenceId,
    ].every(side.containsKey);
    // Lock the anatomical side for this tracking run. Tiny score differences
    // must not swap the two skeletons or their filter histories every frame.
    final useLeft =
        _useLeft ??
        (complete(left) && (!complete(right) || leftScore >= rightScore));
    final primary = useLeft ? left : right;
    final secondary = useLeft ? right : left;
    final confidence = useLeft ? leftScore : rightScore;

    final shoulder = primary[LandmarkId.shoulder];
    final hip = primary[LandmarkId.hip];
    final knee = primary[LandmarkId.knee];
    final ankle = primary[LandmarkId.ankle];

    // Keep the reference on the same anatomical side as well. Switching from
    // a two-wrist midpoint to a single wrist during occlusion creates a jump
    // even when the athlete is standing still.
    final tracked = primary[referenceId];

    if (shoulder == null ||
        hip == null ||
        knee == null ||
        ankle == null ||
        tracked == null ||
        confidence < 0.4) {
      return VisionFrame(
        frame: PoseFrame(
          timestampMs: timestampMs,
          imageSize: imageSize,
          landmarks: primary,
          secondaryLandmarks: secondary,
          trackedPoint: const Offset(0.5, 0.5),
          pattern: pattern,
          hasPose: false,
          isCameraFrame: true,
          trackingId: _trackingId,
        ),
        confidence: 0,
        bodyPixelHeight: 0,
      );
    }

    _useLeft = useLeft;
    final body = head != null
        ? (ankle.dy - head.dy).abs() * imageSize.height
        : 0.0;
    return VisionFrame(
      frame: PoseFrame(
        timestampMs: timestampMs,
        imageSize: imageSize,
        landmarks: primary,
        secondaryLandmarks: secondary,
        trackedPoint: tracked,
        pattern: pattern,
        hasPose: true,
        isCameraFrame: true,
        trackingId: _trackingId,
      ),
      confidence: confidence,
      bodyPixelHeight: body,
    );
  }
}

class VisionFrame {
  const VisionFrame({
    required this.frame,
    required this.confidence,
    required this.bodyPixelHeight,
  });

  final PoseFrame frame;
  final double confidence;
  final double bodyPixelHeight;
}
