import 'dart:ui';

import 'package:camera/camera.dart';

import 'pose_models.dart';

/// Web/desktop fallback. Real inference only runs on Android/iOS; the web demo
/// keeps the simulated pose source.
class VisionPoseSource implements PoseFrameSource {
  VisionPoseSource({
    required CameraController controller,
    required this.pattern,
    this.userHeightCm = 175,
    int framesPerSecond = 15,
  });

  static bool get isSupported => false;

  final MotionPattern pattern;
  final double userHeightCm;

  bool get hasPose => false;
  double get confidence => 0;
  double get bodyPixelHeight => 0;
  String? get lastError => null;

  Future<void> start() async {}
  Future<void> stop() async {}
  void setPaused(bool paused) {}

  @override
  double get totalSeconds => 0;

  @override
  PoseFrame frameAt(double seconds) => PoseFrame(
    timestampMs: seconds * 1000,
    imageSize: const Size(1, 1),
    landmarks: const {},
    trackedPoint: const Offset(0.5, 0.5),
    pattern: pattern,
    hasPose: false,
  );
}
