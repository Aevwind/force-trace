import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_models.dart';
import 'vision_frame_throttle.dart';
import 'vision_pose_mapper.dart';

/// Real on-device pose inference using Google ML Kit.
///
/// ML Kit runs natively (platform channels) and returns 33 body landmarks.
/// This adapter normalizes them and feeds the VBT engine with a body/barbell
/// reference point derived from the wrists (pressing/hinging), shoulders
/// (squat) or hips (bodyweight movements). It intentionally runs alongside the
/// camera preview and only keeps the latest result; the 30 Hz engine samples it.
class VisionPoseSource with WidgetsBindingObserver implements PoseFrameSource {
  VisionPoseSource({
    required this.controller,
    required this.pattern,
    this.userHeightCm = 175,
    int framesPerSecond = 15,
  }) : _throttle = VisionFrameThrottle(framesPerSecond: framesPerSecond),
       _mapper = VisionPoseMapper(pattern: pattern);

  static bool get isSupported => true;

  final CameraController controller;
  final MotionPattern pattern;
  final double userHeightCm;
  final VisionFrameThrottle _throttle;
  final VisionPoseMapper _mapper;
  final Stopwatch _clock = Stopwatch();
  static const _staleAfterMs = 500;

  PoseDetector? _detector;
  bool _running = false;
  bool _paused = false;
  bool _appActive = true;
  int _trackingGeneration = 0;
  Future<void>? _inFlight;
  VisionFrame? _latest;
  String? _error;

  VisionFrame? get _current {
    final latest = _latest;
    if (latest == null ||
        _clock.elapsedMicroseconds / 1000 - latest.frame.timestampMs >
            _staleAfterMs) {
      return null;
    }
    return latest;
  }

  bool get hasPose => _current != null;
  double get confidence => _current?.confidence ?? 0;

  /// Nose-to-ankle pixel height in the current rotated image, used for a real
  /// height-based calibration when the full body is visible.
  double get bodyPixelHeight => _current?.bodyPixelHeight ?? 0;
  String? get lastError => _error;

  @override
  double get totalSeconds => 3600;

  /// Keep the preview available during a rest without running the pose model.
  void setPaused(bool paused) {
    _paused = paused;
    if (paused) _clearTracking();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    if (!_appActive) _clearTracking();
  }

  void _clearTracking() {
    _trackingGeneration++;
    _latest = null;
    _mapper.reset();
    _throttle.reset();
  }

  Future<void> start() async {
    if (_running) return;
    _error = null;
    _clearTracking();
    _clock.start();
    final binding = WidgetsBinding.instance;
    _appActive =
        binding.lifecycleState == null ||
        binding.lifecycleState == AppLifecycleState.resumed;
    binding.addObserver(this);
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ),
    );
    _running = true;
    try {
      await controller.startImageStream(_onImage);
      debugPrint(
        '[vision] stream started ${controller.description.lensDirection} '
        '${controller.value.deviceOrientation} '
        '${controller.description.sensorOrientation}°',
      );
    } catch (error) {
      _running = false;
      binding.removeObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _clearTracking();
    try {
      await controller.stopImageStream();
    } catch (_) {
      // The controller can already be disposed when a route pops.
    }
    // Never close a native detector while processImage is still using it.
    await _inFlight;
    try {
      await _detector?.close();
    } catch (_) {
      // Best effort.
    }
    _detector = null;
  }

  void _onImage(CameraImage image) {
    if (!_running || _paused || !_appActive || _inFlight != null) return;
    final now = _clock.elapsed;
    if (!_throttle.accept(now)) return;
    final operation = _process(image, now.inMicroseconds / 1000);
    _inFlight = operation;
    unawaited(operation.whenComplete(() => _inFlight = null));
  }

  Future<void> _process(CameraImage image, double timestampMs) async {
    final detector = _detector;
    if (detector == null) return;
    final generation = _trackingGeneration;
    try {
      final input = _inputImage(image);
      if (input == null) return;
      final poses = await detector.processImage(input);
      if (!_running ||
          _paused ||
          !_appActive ||
          generation != _trackingGeneration ||
          detector != _detector) {
        return;
      }
      if (poses.isEmpty) return;
      if (_current == null) _mapper.reset();
      final metadata = input.metadata!;
      final rotation = metadata.rotation.rawValue;
      final rotated = rotation == 90 || rotation == 270;
      final result = _mapper.map(
        poses.first,
        imageSize: rotated
            ? Size(metadata.size.height, metadata.size.width)
            : metadata.size,
        mirror:
            controller.description.lensDirection == CameraLensDirection.front,
        timestampMs: timestampMs,
      );
      // Brief occlusions hold the last good pose for a time-based grace period,
      // independent of the detector's frame rate. It expires even on errors.
      if (result.frame.hasPose) _latest = result;
      _error = null;
    } catch (error) {
      if (!_running ||
          generation != _trackingGeneration ||
          detector != _detector) {
        return;
      }
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

  @override
  PoseFrame frameAt(double seconds) {
    return _current?.frame ??
        PoseFrame(
          timestampMs: _clock.elapsedMicroseconds / 1000,
          imageSize: _latest?.frame.imageSize ?? const Size(1, 1),
          landmarks: const {},
          trackedPoint: const Offset(0.5, 0.5),
          pattern: pattern,
          hasPose: false,
          isCameraFrame: true,
        );
  }
}
