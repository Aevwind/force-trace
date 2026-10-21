import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_models.dart';

/// Real on-device pose inference using Google ML Kit.
///
/// ML Kit runs natively (platform channels) and returns 33 normalized body
/// landmarks. This adapter feeds the existing VBT engine with a body/barbell
/// reference point derived from the wrists (pressing/hinging), shoulders
/// (squat) or hips (bodyweight movements). It intentionally runs alongside the
/// camera preview and only keeps the latest result; the 30 Hz engine samples it.
class VisionPoseSource implements PoseFrameSource {
  VisionPoseSource({
    required this.controller,
    required this.pattern,
    this.userHeightCm = 175,
  });

  static bool get isSupported => true;

  final CameraController controller;
  final MotionPattern pattern;
  final double userHeightCm;

  PoseDetector? _detector;
  bool _running = false;
  bool _processing = false;
  int _misses = 0;
  VisionFrame? _latest;
  String? _error;

  bool get hasPose => _latest?.frame.hasPose ?? false;
  double get confidence => _latest?.confidence ?? 0;

  /// Nose-to-ankle pixel height in the current rotated image, used for a real
  /// height-based calibration when the full body is visible.
  double get bodyPixelHeight => _latest?.bodyPixelHeight ?? 0;
  String? get lastError => _error;

  @override
  double get totalSeconds => 3600;

  Future<void> start() async {
    if (_running) return;
    _error = null;
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ),
    );
    try {
      await controller.startImageStream(_onImage);
      _running = true;
      debugPrint(
        '[vision] stream started ${controller.description.lensDirection} '
        '${controller.value.deviceOrientation} '
        '${controller.description.sensorOrientation}°',
      );
    } catch (error) {
      _error = '$error';
      debugPrint('[vision] stream start failed: $error');
      await _detector?.close();
      _detector = null;
      rethrow;
    }
  }

  Future<void> stop() async {
    if (!_running && _detector == null) return;
    _running = false;
    _latest = null;
    _misses = 0;
    try {
      await controller.stopImageStream();
    } catch (_) {
      // The controller can already be disposed when a route pops.
    }
    try {
      await _detector?.close();
    } catch (_) {
      // Best effort.
    }
    _detector = null;
  }

  void _onImage(CameraImage image) {
    if (!_running || _processing) return;
    _processing = true;
    unawaited(
      _process(image).whenComplete(() {
        _processing = false;
      }),
    );
  }

  Future<void> _process(CameraImage image) async {
    final detector = _detector;
    if (detector == null) return;
    final input = _inputImage(image);
    if (input == null) return;
    try {
      final poses = await detector.processImage(input);
      if (poses.isEmpty) {
        _misses++;
        if (_misses >= 12) _latest = null;
        return;
      }
      _misses = 0;
      _latest = _mapPose(poses.first, input);
    } catch (error) {
      _error = '$error';
      debugPrint('[vision] process failed: $error');
    }
  }

  InputImage? _inputImage(CameraImage image) {
    if (image.planes.isEmpty) return null;
    final format = switch (image.format.group) {
      ImageFormatGroup.nv21 => InputImageFormat.nv21,
      ImageFormatGroup.bgra8888 => InputImageFormat.bgra8888,
      ImageFormatGroup.yuv420 => InputImageFormat.yuv_420_888,
      _ => InputImageFormatValue.fromRawValue(image.format.raw),
    };
    if (format == null) return null;
    final rotation = _rotation();
    if (rotation == null) return null;

    // CameraX commonly hands back three YUV planes even when NV21 was
    // requested. ML Kit's byte-input API wants one interleaved NV21 buffer.
    if (image.planes.length >= 3 && format != InputImageFormat.bgra8888) {
      final nv21 = _toNv21(image);
      if (nv21 == null) return null;
      return InputImage.fromBytes(
        bytes: nv21,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
    }

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Uint8List? _toNv21(CameraImage image) {
    if (image.planes.length < 3) return null;
    final width = image.width;
    final height = image.height;
    final y = image.planes[0];
    final u = image.planes[1];
    final v = image.planes[2];
    final out = Uint8List(width * height + (width * height ~/ 2));

    for (var row = 0; row < height; row++) {
      final start = row * y.bytesPerRow;
      if (start + width > y.bytes.length) return null;
      out.setRange(row * width, row * width + width, y.bytes, start);
    }

    final uStep = u.bytesPerPixel ?? 1;
    final vStep = v.bytesPerPixel ?? 1;
    var offset = width * height;
    for (var row = 0; row < height ~/ 2; row++) {
      for (var col = 0; col < width ~/ 2; col++) {
        final uIndex = row * u.bytesPerRow + col * uStep;
        final vIndex = row * v.bytesPerRow + col * vStep;
        if (uIndex >= u.bytes.length || vIndex >= v.bytes.length) return null;
        out[offset++] = v.bytes[vIndex];
        out[offset++] = u.bytes[uIndex];
      }
    }
    return out;
  }

  InputImageRotation? _rotation() {
    final sensor = controller.description.sensorOrientation;
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(sensor);
    }
    final device = switch (controller.value.deviceOrientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeLeft => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeRight => 270,
    };
    final lens = controller.description.lensDirection;
    final degrees = lens == CameraLensDirection.front
        ? (sensor + device) % 360
        : (sensor - device + 360) % 360;
    return InputImageRotationValue.fromRawValue(degrees);
  }

  VisionFrame _mapPose(Pose pose, InputImage input) {
    final metadata = input.metadata!;
    final rotation = metadata.rotation.rawValue;
    final rotated = rotation == 90 || rotation == 270;
    final imageSize = rotated
        ? Size(metadata.size.height, metadata.size.width)
        : metadata.size;
    // CameraPreview mirrors the front lens; mirror the normalized landmarks so
    // the skeleton stays aligned with what the user sees.
    final mirror =
        controller.description.lensDirection == CameraLensDirection.front;

    Offset? point(PoseLandmarkType type, {double minLikelihood = 0.25}) {
      final landmark = pose.landmarks[type];
      if (landmark == null || landmark.likelihood < minLikelihood) return null;
      // google_mlkit_pose_detection returns landmark positions in image pixels
      // for some ML Kit versions; older docs describe them as normalized. Handle
      // both representations without shrinking an already-normalized point.
      var x = landmark.x;
      var y = landmark.y;
      if (x > 1.0 || y > 1.0) {
        x /= imageSize.width;
        y /= imageSize.height;
      }
      x = x.clamp(0.0, 1.0);
      y = y.clamp(0.0, 1.0);
      return Offset(mirror ? 1 - x : x, y);
    }

    double score(List<PoseLandmarkType> types) {
      var sum = 0.0;
      var count = 0;
      for (final type in types) {
        final landmark = pose.landmarks[type];
        if (landmark == null) continue;
        sum += landmark.likelihood;
        count++;
      }
      return count == 0 ? 0 : sum / count;
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
    final useLeft = leftScore >= rightScore;

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

    final primary = sideMap(useLeft);
    final secondary = sideMap(!useLeft);
    // Fill a missing primary joint from the other side for the full-body
    // validity check, while keeping the opposite side for the second skeleton.
    for (final entry in secondary.entries) {
      primary.putIfAbsent(entry.key, () => entry.value);
    }

    final shoulder = primary[LandmarkId.shoulder];
    final hip = primary[LandmarkId.hip];
    final knee = primary[LandmarkId.knee];
    final ankle = primary[LandmarkId.ankle];

    // The reference point that best approximates the moving barbell/body:
    // - squat: bar rests on the upper back -> shoulder midpoint
    // - bench/press/hinge/curl: hands hold the bar -> wrist midpoint
    // - pull-up/push-up: body reference (hips/shoulders)
    final bar = switch (pattern) {
      MotionPattern.squat => midpoint(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
      ),
      MotionPattern.bench ||
      MotionPattern.press ||
      MotionPattern.hinge ||
      MotionPattern.curl => midpoint(
        PoseLandmarkType.leftWrist,
        PoseLandmarkType.rightWrist,
      ),
      MotionPattern.pullup => midpoint(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,
      ),
      MotionPattern.pushup => midpoint(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
      ),
    };

    if (shoulder == null ||
        hip == null ||
        knee == null ||
        ankle == null ||
        ((leftScore + rightScore) / 2) < 0.4) {
      return VisionFrame(
        frame: PoseFrame(
          timestampMs: DateTime.now().millisecondsSinceEpoch.toDouble(),
          imageSize: imageSize,
          landmarks: primary,
          secondaryLandmarks: secondary,
          trackedPoint: const Offset(0.5, 0.5),
          pattern: pattern,
          hasPose: false,
          isCameraFrame: true,
        ),
        confidence: 0,
        bodyPixelHeight: 0,
      );
    }

    final confidence = (leftScore + rightScore) / 2;
    final body = head != null
        ? (ankle.dy - head.dy).abs() * imageSize.height
        : 0.0;
    final tracked = bar ?? shoulder;
    return VisionFrame(
      frame: PoseFrame(
        timestampMs: DateTime.now().millisecondsSinceEpoch.toDouble(),
        imageSize: imageSize,
        landmarks: primary,
        secondaryLandmarks: secondary,
        trackedPoint: tracked,
        pattern: pattern,
        hasPose: true,
        isCameraFrame: true,
      ),
      confidence: confidence,
      bodyPixelHeight: body,
    );
  }

  @override
  PoseFrame frameAt(double seconds) {
    return _latest?.frame ??
        PoseFrame(
          timestampMs: seconds * 1000,
          imageSize: const Size(1, 1),
          landmarks: const {},
          trackedPoint: const Offset(0.5, 0.5),
          pattern: pattern,
          hasPose: false,
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
