import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Owns an optional live camera preview. On platforms without camera support
/// (or when permission is denied) [error] is set and the demo scene remains.
class CameraSession extends ChangeNotifier {
  CameraController? _controller;
  bool _initializing = false;
  String? _error;
  CameraLensDirection _preferredLens = CameraLensDirection.front;

  CameraController? get controller => _controller;
  bool get active => _controller != null;
  bool get initializing => _initializing;
  String? get error => _error;
  CameraLensDirection get lensDirection =>
      _controller?.description.lensDirection ?? _preferredLens;
  bool get isFront => lensDirection == CameraLensDirection.front;

  Future<void> toggle() async {
    if (active) {
      await disable();
    } else {
      await enable();
    }
  }

  Future<void> flip() async {
    if (_initializing) return;
    _preferredLens = _preferredLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    if (active) {
      await disable();
      await enable();
    } else {
      await enable();
    }
  }

  Future<void> enable() async {
    if (_initializing || active) return;
    _initializing = true;
    _error = null;
    notifyListeners();
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera available');
      }
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == _preferredLens,
        orElse: () => cameras.first,
      );
      _preferredLens = camera.lensDirection;
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        fps: 15,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      _controller = controller;
    } catch (error) {
      _error = '$error';
      _controller = null;
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> disable() async {
    final controller = _controller;
    _controller = null;
    notifyListeners();
    try {
      await controller?.stopImageStream();
    } catch (_) {
      // No active stream.
    }
    try {
      await controller?.dispose();
    } catch (_) {
      // A disposed platform view can throw; it should not crash the HUD.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}

class CameraPreviewView extends StatelessWidget {
  const CameraPreviewView({
    super.key,
    required this.controller,
    this.opacity = 1.0,
  });

  final CameraController controller;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return const SizedBox.shrink();
    return ClipRect(
      child: Opacity(
        opacity: opacity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 720,
            height: controller.value.previewSize?.width ?? 1280,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class CameraPreviewLayer extends StatelessWidget {
  const CameraPreviewLayer({
    super.key,
    required this.session,
    this.opacity = 0.34,
  });

  final CameraSession session;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final controller = session.controller;
        if (controller == null) return const SizedBox.shrink();
        return CameraPreviewView(controller: controller, opacity: opacity);
      },
    );
  }
}
