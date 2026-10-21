import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';
import '../../domain/vbt/calibration.dart';
import '../../domain/vbt/pose_models.dart';
import '../../domain/vbt/vision_pose_source.dart';
import '../../services/camera_session.dart';
import '../../services/tilt_service.dart';

class CalibrationPage extends ConsumerStatefulWidget {
  const CalibrationPage({
    super.key,
    required this.exercise,
    this.existing,
    this.camera,
  });

  final Exercise exercise;
  final Calibration? existing;
  final CameraController? camera;

  @override
  ConsumerState<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends ConsumerState<CalibrationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  StreamSubscription<double>? _tiltSubscription;
  Timer? _sensorTimer;
  Timer? _visionTimer;
  VisionPoseSource? _visionSource;
  double _bodyPixelHeight = 0;
  double _visionConfidence = 0;
  bool _visionError = false;

  CalibrationMethod _method = CalibrationMethod.plate;
  double _plateDiameterCm = 45;
  double _heightCm = 175;
  PlateDetection? _detection;
  bool _scanning = false;
  double _tilt = 0;
  bool _tiltSensorAlive = false;
  bool _tiltEverReceived = false;
  bool _detectionDone = false;

  bool get _cameraLive =>
      widget.camera != null && widget.camera!.value.isInitialized;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).value;
    _plateDiameterCm = settings.plateDiameterCm;
    _heightCm = settings.userHeightCm;
    _tiltSubscription = TiltService().tiltStream().listen((value) {
      if (!mounted) return;
      setState(() {
        _tilt = value;
        _tiltSensorAlive = true;
        _tiltEverReceived = true;
      });
    }, onError: (_) {});
    _sensorTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted && !_tiltEverReceived) {
        setState(() => _tiltSensorAlive = false);
      }
    });
    unawaited(_startVision());
  }

  Future<void> _startVision() async {
    final camera = widget.camera;
    if (camera == null ||
        !camera.value.isInitialized ||
        !VisionPoseSource.isSupported) {
      return;
    }
    try {
      final source = VisionPoseSource(
        controller: camera,
        pattern: MotionPattern.squat,
        userHeightCm: _heightCm,
      );
      await source.start();
      if (!mounted) {
        await source.stop();
        return;
      }
      setState(() => _visionSource = source);
      _visionTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (!mounted) return;
        final body = source.bodyPixelHeight;
        final confidence = source.confidence;
        final error = source.lastError != null;
        if (body != _bodyPixelHeight ||
            confidence != _visionConfidence ||
            error != _visionError) {
          setState(() {
            _bodyPixelHeight = body;
            _visionConfidence = confidence;
            _visionError = error;
          });
        }
      });
    } catch (_) {
      if (mounted) setState(() => _visionError = true);
    }
  }

  Future<void> _stopVision() async {
    _visionTimer?.cancel();
    _visionTimer = null;
    final source = _visionSource;
    _visionSource = null;
    await source?.stop();
  }

  @override
  void dispose() {
    _tiltSubscription?.cancel();
    _sensorTimer?.cancel();
    _visionTimer?.cancel();
    final vision = _visionSource;
    _visionSource = null;
    unawaited(vision?.stop());
    _scanController.dispose();
    super.dispose();
  }

  Calibration? get _calibration {
    if (_method == CalibrationMethod.height) {
      // Height calibration is only real when the camera is live and a full
      // body has been measured by ML Kit. Without that, do not silently fall
      // back to the old fixed 675 px assumption.
      if (!_cameraLive || _bodyPixelHeight <= 1) return null;
      return Calibration.fromHeight(
        userHeightCm: _heightCm,
        bodyPixelHeight: _bodyPixelHeight,
        tiltDegrees: _tilt,
      );
    }
    final detection = _detection;
    if (detection == null) return null;
    return Calibration.fromPlate(
      plateDiameterCm: _plateDiameterCm,
      platePixelDiameter: detection.pixelDiameter,
      tiltDegrees: _tilt,
      userHeightCm: _heightCm,
      confidence: detection.confidence,
    );
  }

  Future<void> _detectPlate() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _detectionDone = false;
      _detection = null;
    });
    _scanController.repeat();
    await Future<void>.delayed(const Duration(milliseconds: 1250));
    if (!mounted) return;
    _scanController.stop();
    final jitter = math.Random().nextDouble() * 3.6 - 1.8;
    setState(() {
      _scanning = false;
      _detectionDone = true;
      _detection = PlateDetection(
        pixelDiameter: 120 + jitter,
        confidence: 0.96,
      );
    });
  }

  Future<void> _useDefaultScale() async {
    final calibration = Calibration.fromPlate(
      plateDiameterCm: _plateDiameterCm,
      platePixelDiameter: 120,
      tiltDegrees: _tilt,
      userHeightCm: _heightCm,
      method: CalibrationMethod.quick,
      confidence: 0.6,
    );
    if (calibration == null) return;
    await _stopVision();
    if (!mounted) return;
    Navigator.of(context).pop(calibration);
  }

  Future<void> _confirm() async {
    final calibration = _calibration;
    if (calibration == null) {
      showAppSnack(
        context,
        _method == CalibrationMethod.height
            ? (context.isZh
                  ? '请让头部、髋、膝、踝完整入镜，等待全身识别'
                  : 'Keep your head, hips, knees and ankles in frame until the full body is detected')
            : (context.isZh ? '请先完成杠铃片识别' : 'Detect the plate first'),
        error: true,
      );
      return;
    }
    await _stopVision();
    if (!mounted) return;
    Navigator.of(context).pop(calibration);
  }

  @override
  Widget build(BuildContext context) {
    final calibration = _calibration;
    final tiltOk = _tilt.abs() < 8 || _tilt.abs() > 55;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          if (_cameraLive)
            Positioned.fill(
              child: CameraPreviewView(
                controller: widget.camera!,
                opacity: 0.55,
              ),
            )
          else
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: CalibrationScenePainter(
                      scanning: _scanning,
                      scanProgress: _scanController.value,
                      detected: _detectionDone,
                      plateDiameter: _plateDiameterCm,
                    ),
                  );
                },
              ),
            ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 21),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t('calibrationTitle'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              widget.exercise.displayName(
                                Localizations.localeOf(context).languageCode,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.dim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TierBadge(tierValue: widget.exercise.tier.value),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _LiveCalibrationStatus(
                    cameraLive: _cameraLive,
                    hasBody: _bodyPixelHeight > 1,
                    bodyPixelHeight: _bodyPixelHeight,
                    confidence: _visionConfidence,
                    error: _visionError,
                    method: _method,
                    locale: Localizations.localeOf(context).languageCode,
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: GlassPanel(
                      radius: 12,
                      blur: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tiltOk
                                ? Icons.check_circle_outline_rounded
                                : Icons.warning_amber_rounded,
                            size: 14,
                            color: tiltOk ? AppColors.green : AppColors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.t('framingHint'),
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                _CalibrationPanel(
                  method: _method,
                  onMethodChanged: (value) => setState(() => _method = value),
                  plateDiameterCm: _plateDiameterCm,
                  onPlateDiameterChanged: (value) =>
                      setState(() => _plateDiameterCm = value),
                  heightCm: _heightCm,
                  onHeightChanged: (value) => setState(() => _heightCm = value),
                  bodyPixelHeight: _bodyPixelHeight,
                  detection: _detection,
                  scanning: _scanning,
                  tilt: _tilt,
                  tiltSensorAlive: _tiltSensorAlive,
                  calibration: calibration,
                  onDetect: _detectPlate,
                  onConfirm: _confirm,
                  onUseDefault: _useDefaultScale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCalibrationStatus extends StatelessWidget {
  const _LiveCalibrationStatus({
    required this.cameraLive,
    required this.hasBody,
    required this.bodyPixelHeight,
    required this.confidence,
    required this.error,
    required this.method,
    required this.locale,
  });

  final bool cameraLive;
  final bool hasBody;
  final double bodyPixelHeight;
  final double confidence;
  final bool error;
  final CalibrationMethod method;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final zh = locale == 'zh';
    late final String text;
    late final Color color;
    if (!cameraLive) {
      color = AppColors.orange;
      text = zh ? '相机未开启：片径自动识别仍是演示；身高标定需要先开启相机' : 'Camera off: plate detection is still a demo; enable the camera for real height calibration';
    } else if (error) {
      color = AppColors.orange;
      text = zh
          ? '视觉推理暂不可用；请检查 ML Kit 初始化或重试'
          : 'Vision inference unavailable; check ML Kit initialization';
    } else if (method == CalibrationMethod.height) {
      if (hasBody) {
        color = AppColors.green;
        text = zh
            ? '真实身高标定 · 鼻-踝 ${bodyPixelHeight.round()} px · 置信度 ${(confidence * 100).round()}%'
            : 'Real height calibration · nose-ankle ${bodyPixelHeight.round()} px · ${(confidence * 100).round()}% confidence';
      } else {
        color = AppColors.orange;
        text = zh ? '请后退至全身入镜（头、肩、髋、膝、踝）' : 'Step back until your head, shoulders, hips, knees and ankles are visible';
      }
    } else {
      color = AppColors.orange;
      text = zh ? '自动片径仍为演示；切换「身高标定」可使用真实比例尺' : 'Automatic plate detection is a demo; use Height calibration for a real scale';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            error || !cameraLive
                ? Icons.warning_amber_rounded
                : hasBody && method == CalibrationMethod.height
                ? Icons.verified_rounded
                : Icons.center_focus_strong_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 9.5, height: 1.4, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationPanel extends StatelessWidget {
  const _CalibrationPanel({
    required this.method,
    required this.onMethodChanged,
    required this.plateDiameterCm,
    required this.onPlateDiameterChanged,
    required this.heightCm,
    required this.onHeightChanged,
    required this.bodyPixelHeight,
    required this.detection,
    required this.scanning,
    required this.tilt,
    required this.tiltSensorAlive,
    required this.calibration,
    required this.onDetect,
    required this.onConfirm,
    required this.onUseDefault,
  });

  final CalibrationMethod method;
  final ValueChanged<CalibrationMethod> onMethodChanged;
  final double plateDiameterCm;
  final ValueChanged<double> onPlateDiameterChanged;
  final double heightCm;
  final ValueChanged<double> onHeightChanged;
  final double bodyPixelHeight;
  final PlateDetection? detection;
  final bool scanning;
  final double tilt;
  final bool tiltSensorAlive;
  final Calibration? calibration;
  final VoidCallback onDetect;
  final VoidCallback onConfirm;
  final VoidCallback onUseDefault;

  @override
  Widget build(BuildContext context) {
    final tiltOk = tilt.abs() < 8 || tilt.abs() > 55;
    final portrait = tilt.abs() > 55;
    final zh = context.isZh;
    final tiltLabel = tiltOk
        ? (portrait
              ? (zh ? '机位竖放，透视畸变很小' : 'Portrait mount — minimal distortion')
              : context.t('tiltGood'))
        : (zh
              ? '请将手机竖放固定，或水平放置'
              : 'Mount the phone upright (portrait) or level');
    return GlassPanel(
      radius: 26,
      blur: 24,
      tint: const Color(0xF20C141B),
      borderColor: Colors.white.withValues(alpha: 0.1),
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.52,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.center_focus_strong_rounded,
                      size: 16,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    context.t('calibrationTitle'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (calibration != null)
                    Text(
                      'k = ${calibration!.metersPerPixel.toStringAsFixed(5)}',
                      style: numericStyle(
                        size: 11,
                        color: AppColors.green,
                        weight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.t('calibrationIntro'),
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.55,
                  color: AppColors.dim,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _BubbleLevel(tilt: tilt),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tiltLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: tiltOk ? AppColors.green : AppColors.orange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tiltSensorAlive
                              ? '${tilt.toStringAsFixed(1)}°'
                              : context.t('sensorsUnavailable'),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.dim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.strokeSoft),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _MethodButton(
                        label: context.t('methodPlate'),
                        selected: method == CalibrationMethod.plate,
                        onTap: () => onMethodChanged(CalibrationMethod.plate),
                      ),
                    ),
                    Expanded(
                      child: _MethodButton(
                        label: context.t('methodHeight'),
                        selected: method == CalibrationMethod.height,
                        onTap: () => onMethodChanged(CalibrationMethod.height),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (method == CalibrationMethod.plate) ...[
                Row(
                  children: [
                    for (final diameter in [35.0, 45.0, 50.0])
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text('${diameter.round()} cm'),
                          selected: plateDiameterCm == diameter,
                          onSelected: (_) => onPlateDiameterChanged(diameter),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: scanning ? null : onDetect,
                        icon: scanning
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                ),
                              )
                            : const Icon(
                                Icons.filter_center_focus_rounded,
                                size: 17,
                              ),
                        label: Text(
                          scanning
                              ? context.t('scanning')
                              : context.t('autoDetect'),
                        ),
                      ),
                    ),
                  ],
                ),
                if (detection != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'D = ${detection!.pixelDiameter.toStringAsFixed(1)} px · '
                            '${(detection!.confidence * 100).round()}% · '
                            'k = ${((plateDiameterCm / 100) / detection!.pixelDiameter).toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 7),
                Text(
                  context.isZh
                      ? '演示检测：接入 YOLOv8 后自动识别真实片径'
                      : 'Demo detection — YOLOv8 will detect the real plate',
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: AppColors.dim,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Text(
                      '${context.t('heightHint')} ${heightCm.round()} cm',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      bodyPixelHeight > 1
                          ? '${bodyPixelHeight.round()} px'
                          : '— px',
                      style: numericStyle(
                        size: 10,
                        color: bodyPixelHeight > 1
                            ? AppColors.green
                            : AppColors.dim,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: heightCm,
                  min: 140,
                  max: 210,
                  divisions: 70,
                  onChanged: onHeightChanged,
                ),
                Text(
                  context.t('heightDetectHint'),
                  style: const TextStyle(
                    fontSize: 9,
                    height: 1.5,
                    color: AppColors.dim,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('scaleFactor'),
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: AppColors.dim,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          calibration == null
                              ? '—'
                              : '${calibration!.metersPerPixel.toStringAsFixed(5)} m/px',
                          style: numericStyle(
                            size: 14,
                            color: calibration == null
                                ? AppColors.dim
                                : AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 168,
                    child: GradientButton(
                      label: calibration == null
                          ? (context.isZh ? '使用默认标定' : 'Use default')
                          : context.t('confirmCalibration'),
                      onPressed: calibration == null ? onUseDefault : onConfirm,
                      height: 46,
                      icon: calibration == null
                          ? Icons.skip_next_rounded
                          : Icons.check_rounded,
                    ),
                  ),
                ],
              ),
              if (calibration == null) ...[
                const SizedBox(height: 6),
                Text(
                  context.isZh
                      ? '检测不到完整身体或片径时，可先用默认 45 cm 比例尺继续；速度/ROM 仅作相对参考。'
                      : 'If the full body or plate is not visible, continue with the default 45 cm scale; speed/ROM will be relative.',
                  style: const TextStyle(
                    fontSize: 8.5,
                    height: 1.45,
                    color: AppColors.dim,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.green.withValues(alpha: 0.13)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.green : AppColors.dim,
          ),
        ),
      ),
    );
  }
}

class _BubbleLevel extends StatelessWidget {
  const _BubbleLevel({required this.tilt});

  final double tilt;

  @override
  Widget build(BuildContext context) {
    final ok = tilt.abs() < 8 || tilt.abs() > 55;
    final color = ok ? AppColors.green : AppColors.orange;
    return Container(
      width: 94,
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final range = (constraints.maxWidth - 20) / 2;
          final offset = ok ? 0.0 : (tilt / 20).clamp(-1.0, 1.0) * range;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Center(
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 120),
                left: constraints.maxWidth / 2 - 5 + offset,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CalibrationScenePainter extends CustomPainter {
  CalibrationScenePainter({
    required this.scanning,
    required this.scanProgress,
    required this.detected,
    required this.plateDiameter,
  });

  final bool scanning;
  final double scanProgress;
  final bool detected;
  final double plateDiameter;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF101A22), Color(0xFF05080B)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final side = math.min(size.width * 0.9, size.height * 0.38);
    final stage = Rect.fromLTWH(
      (size.width - side) / 2,
      size.height * 0.12,
      side,
      side,
    );

    // Dashed framing guide with corner brackets.
    final guide = Paint()
      ..color = AppColors.green.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dash = 7.0;
    const gap = 6.0;
    final frame = Rect.fromLTWH(
      stage.left + side * 0.08,
      stage.top + side * 0.05,
      side * 0.84,
      side * 0.88,
    );
    void dashedLine(Offset a, Offset b) {
      final distance = (b - a).distance;
      final direction = (b - a) / distance;
      var travelled = 0.0;
      while (travelled < distance) {
        final end = math.min(travelled + dash, distance);
        canvas.drawLine(a + direction * travelled, a + direction * end, guide);
        travelled = end + gap;
      }
    }

    dashedLine(frame.topLeft, frame.topRight);
    dashedLine(frame.bottomRight, frame.bottomLeft);
    dashedLine(frame.topLeft, frame.bottomLeft);
    dashedLine(frame.topRight, frame.bottomRight);
    for (final corner in [
      frame.topLeft,
      frame.topRight,
      frame.bottomLeft,
      frame.bottomRight,
    ]) {
      canvas.drawCircle(corner, 2, Paint()..color = AppColors.green);
    }

    final floor = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(stage.left, stage.top + side * 0.9),
      Offset(stage.right, stage.top + side * 0.9),
      floor,
    );

    // Standing athlete.
    final points = <String, Offset>{
      'head': Offset(stage.left + side * 0.56, stage.top + side * 0.225),
      'shoulder': Offset(stage.left + side * 0.57, stage.top + side * 0.30),
      'elbow': Offset(stage.left + side * 0.55, stage.top + side * 0.38),
      'wrist': Offset(stage.left + side * 0.56, stage.top + side * 0.285),
      'hip': Offset(stage.left + side * 0.59, stage.top + side * 0.56),
      'knee': Offset(stage.left + side * 0.62, stage.top + side * 0.73),
      'ankle': Offset(stage.left + side * 0.62, stage.top + side * 0.90),
    };

    final ghost = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = side * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final ghostPath = Path()
      ..moveTo(points['shoulder']!.dx, points['shoulder']!.dy)
      ..lineTo(points['hip']!.dx, points['hip']!.dy)
      ..lineTo(points['knee']!.dx, points['knee']!.dy)
      ..lineTo(points['ankle']!.dx, points['ankle']!.dy);
    canvas.drawPath(ghostPath, ghost);
    canvas.drawCircle(points['head']!, side * 0.032, ghost);

    final body = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    void segment(String a, String b) {
      canvas.drawLine(points[a]!, points[b]!, shadow);
      canvas.drawLine(points[a]!, points[b]!, body);
    }

    segment('shoulder', 'hip');
    segment('hip', 'knee');
    segment('knee', 'ankle');
    segment('shoulder', 'elbow');
    segment('elbow', 'wrist');
    segment('shoulder', 'head');
    for (final key in ['shoulder', 'hip', 'knee', 'ankle']) {
      canvas.drawCircle(
        points[key]!,
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Plate at the right of the athlete.
    final plateCenter = Offset(
      stage.left + side * 0.83,
      stage.top + side * 0.74,
    );
    final radius = side * 0.06;
    canvas.drawCircle(
      plateCenter,
      radius,
      Paint()..color = const Color(0xFF101820),
    );
    canvas.drawCircle(
      plateCenter,
      radius,
      Paint()
        ..color = AppColors.orange.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      plateCenter,
      radius * 0.62,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      plateCenter,
      radius * 0.16,
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.drawLine(
      plateCenter + Offset(radius, 0),
      plateCenter + Offset(radius * 1.8, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 4,
    );

    final label = TextPainter(
      text: TextSpan(
        text: 'Ø ${plateDiameter.round()} cm',
        style: const TextStyle(
          color: AppColors.orange,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, plateCenter + Offset(-label.width / 2, radius + 8));

    if (scanning) {
      final lineY = plateCenter.dy - radius + radius * 2 * scanProgress;
      final scanPaint = Paint()
        ..color = AppColors.green.withValues(alpha: 0.75)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(plateCenter.dx - radius * 1.15, lineY),
        Offset(plateCenter.dx + radius * 1.15, lineY),
        scanPaint,
      );
      canvas.drawCircle(
        plateCenter,
        radius,
        Paint()
          ..color = AppColors.green.withValues(alpha: 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    if (detected) {
      canvas.drawCircle(
        plateCenter,
        radius + 6,
        Paint()
          ..color = AppColors.green.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      final check = TextPainter(
        text: const TextSpan(
          text: 'DETECTED',
          style: TextStyle(
            color: AppColors.green,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      check.paint(canvas, plateCenter + Offset(-check.width / 2, radius + 20));
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 0.9,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CalibrationScenePainter oldDelegate) {
    return oldDelegate.scanning != scanning ||
        oldDelegate.scanProgress != scanProgress ||
        oldDelegate.detected != detected ||
        oldDelegate.plateDiameter != plateDiameter;
  }
}
