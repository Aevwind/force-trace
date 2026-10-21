import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/domain/vbt/pose_models.dart';
import 'package:force_trace/domain/vbt/vision_pose_source_io.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class _Camera extends CameraController {
  _Camera()
    : super(
        const CameraDescription(
          name: 'test',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 90,
        ),
        ResolutionPreset.medium,
      );

  void Function(CameraImage)? emit;

  @override
  Future<void> startImageStream(void Function(CameraImage) onAvailable) async {
    emit = onAvailable;
  }

  @override
  Future<void> stopImageStream() async => emit = null;
}

class _Format implements ImageFormat {
  @override
  ImageFormatGroup get group => ImageFormatGroup.nv21;
  @override
  dynamic get raw => 17;
}

class _Plane implements Plane {
  @override
  final Uint8List bytes = Uint8List(480 * 640 * 3 ~/ 2);
  @override
  int get bytesPerRow => 480;
  @override
  int get bytesPerPixel => 1;
  @override
  int get width => 480;
  @override
  int get height => 640;
}

class _Image implements CameraImage {
  @override
  ImageFormat get format => _Format();
  @override
  int get width => 480;
  @override
  int get height => 640;
  @override
  final List<Plane> planes = [_Plane()];
  @override
  double? get lensAperture => null;
  @override
  int? get sensorExposureTime => null;
  @override
  double? get sensorSensitivity => null;
}

List<List<Map<String, Object>>> _result() => [
  [
    for (final type in PoseLandmarkType.values)
      {
        'type': type.index,
        'x': type.name.startsWith('left') ? 120.0 : 360.0,
        'y': 240.0,
        'z': 0.0,
        'likelihood': 0.95,
      },
  ],
];

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('google_mlkit_pose_detector');

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'drops bursts and suspends inference during rest or background',
    () async {
      var calls = 0;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'vision#startPoseDetector') {
          calls++;
          return _result();
        }
        return null;
      });
      final camera = _Camera();
      final source = VisionPoseSource(
        controller: camera,
        pattern: MotionPattern.squat,
        framesPerSecond: 1,
      );
      await source.start();
      addTearDown(source.stop);
      final image = _Image();
      for (var i = 0; i < 20; i++) {
        camera.emit!(image);
        await Future<void>.delayed(Duration.zero);
      }
      expect(calls, 1);
      expect(source.hasPose, isTrue);

      source.setPaused(true);
      camera.emit!(image);
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      expect(source.hasPose, isFalse);

      source.setPaused(false);
      source.didChangeAppLifecycleState(AppLifecycleState.paused);
      camera.emit!(image);
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      source.didChangeAppLifecycleState(AppLifecycleState.resumed);
      camera.emit!(image);
      await Future<void>.delayed(Duration.zero);
      expect(calls, 2);
      expect(source.hasPose, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 550));
      expect(source.hasPose, isFalse);
      expect(source.bodyPixelHeight, 0);
      expect(source.frameAt(1).hasPose, isFalse);
    },
  );

  test(
    'a result started before pause cannot leak into a resumed run',
    () async {
      final pending = Completer<Object>();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'vision#startPoseDetector') return pending.future;
        return null;
      });
      final camera = _Camera();
      final source = VisionPoseSource(
        controller: camera,
        pattern: MotionPattern.squat,
      );
      await source.start();
      addTearDown(source.stop);
      camera.emit!(_Image());
      source.setPaused(true);
      source.setPaused(false);
      pending.complete(_result());
      await Future<void>.delayed(Duration.zero);
      expect(source.hasPose, isFalse);
      camera.emit!(_Image());
      await Future<void>.delayed(Duration.zero);
      expect(source.hasPose, isTrue);
    },
  );

  test('stop drains native inference and discards a late result', () async {
    final pending = Completer<Object>();
    var closed = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'vision#startPoseDetector') return pending.future;
      if (call.method == 'vision#closePoseDetector') closed = true;
      return null;
    });
    final camera = _Camera();
    final source = VisionPoseSource(
      controller: camera,
      pattern: MotionPattern.squat,
    );
    await source.start();
    camera.emit!(_Image());
    final stopping = source.stop();
    await Future<void>.delayed(Duration.zero);
    expect(closed, isFalse);
    pending.complete(_result());
    await stopping;
    expect(closed, isTrue);
    expect(source.hasPose, isFalse);
  });
}
