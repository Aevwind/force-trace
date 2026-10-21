import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/vbt/calibration.dart';
import '../../domain/vbt/exercise_profile.dart';
import '../../domain/vbt/pose_models.dart';
import '../../domain/vbt/vbt_engine_controller.dart';
import '../../domain/vbt/vbt_session_engine.dart';
import '../../domain/vbt/vision_pose_source.dart';
import '../../services/camera_session.dart';
import '../report/report_data.dart';
import '../report/report_page.dart';
import 'calibration_page.dart';
import 'widgets/glass_stat_card.dart';
import 'widgets/hud_painter.dart';

class LiveHudPage extends ConsumerStatefulWidget {
  const LiveHudPage({
    super.key,
    required this.exercise,
    required this.targetReps,
    this.initialWeightKg = 0,
    this.planDay,
    this.planItemId,
  });

  final Exercise exercise;
  final int targetReps;
  final double initialWeightKg;
  final String? planDay;
  final int? planItemId;

  @override
  ConsumerState<LiveHudPage> createState() => _LiveHudPageState();
}

class _LiveHudPageState extends ConsumerState<LiveHudPage>
    with WidgetsBindingObserver {
  final ValueNotifier<LiveFrame?> _emptyFrame = ValueNotifier(null);
  late final ExerciseProfile _profile;
  late final CameraSession _camera;
  final GlobalKey _hudKey = GlobalKey();

  Calibration? _calibration;
  VbtEngineController? _controller;
  VisionPoseSource? _visionSource;
  late double _weight;
  bool _saving = false;
  bool _starting = false;
  bool _finishing = false;
  bool _autoStopHandled = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profile = ExerciseProfile.forExercise(widget.exercise);
    _camera = CameraSession();
    _weight = widget.initialWeightKg;
    if (_weight <= 0 &&
        widget.exercise.equipment.toLowerCase().contains('barbell')) {
      _weight = 20;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final vision = _visionSource;
    _visionSource = null;
    unawaited(vision?.stop());
    _controller?.dispose();
    _camera.dispose();
    _emptyFrame.dispose();
    super.dispose();
  }

  bool get _started => _controller != null;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _started) _pause();
  }

  Future<void> _openCalibration() async {
    final result = await pushAppPage<Calibration>(
      context,
      CalibrationPage(
        exercise: widget.exercise,
        existing: _calibration,
        camera: _camera.controller,
      ),
    );
    if (result != null && mounted) {
      setState(() => _calibration = result);
    }
  }

  void _quickCalibrate() {
    final settings = ref.read(settingsProvider).value;
    final calibration = Calibration.fromPlate(
      plateDiameterCm: settings.plateDiameterCm,
      platePixelDiameter: 120,
      userHeightCm: settings.userHeightCm,
      method: CalibrationMethod.quick,
      confidence: 0.9,
    );
    if (calibration == null) return;
    setState(() => _calibration = calibration);
    showAppSnack(
      context,
      context.isZh
          ? '已使用 ${settings.plateDiameterCm.round()} cm 杠铃片快速标定'
          : 'Quick-calibrated with a ${settings.plateDiameterCm.round()} cm plate',
    );
  }

  Future<void> _start() async {
    if (_starting) return;
    _starting = true;
    try {
      await _startSession();
    } finally {
      _starting = false;
    }
  }

  Future<void> _startSession() async {
    if (_started) {
      _resume();
      return;
    }
    if (_calibration == null) {
      await _openCalibration();
      if (_calibration == null || !mounted) return;
    }
    final settings = ref.read(settingsProvider).value;
    final locale = Localizations.localeOf(context).languageCode;

    VisionPoseSource? vision;
    if (_camera.active && VisionPoseSource.isSupported) {
      final cameraController = _camera.controller;
      if (cameraController != null) {
        try {
          vision = VisionPoseSource(
            controller: cameraController,
            pattern: _profile.pattern,
            userHeightCm: settings.userHeightCm,
          );
          await vision.start();
          // Give the detector a short warm-up before publishing the HUD.
          for (var i = 0; i < 24 && !vision.hasPose; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          if (vision.lastError != null) {
            final message = vision.lastError!;
            await vision.stop();
            vision = null;
            if (mounted) {
              showAppSnack(
                context,
                context.isZh
                    ? '视觉推理不可用，已切换为演示姿态：$message'
                    : 'Vision inference unavailable; using the demo pose: $message',
                error: true,
              );
            }
          }
        } catch (_) {
          vision = null;
          if (mounted) {
            showAppSnack(
              context,
              context.isZh
                  ? '视觉推理启动失败，已切换为演示姿态'
                  : 'Vision inference failed; using the demo pose',
              error: true,
            );
          }
        }
      }
    }
    if (!mounted) {
      await vision?.stop();
      return;
    }
    _visionSource = vision;

    final engine = VbtSessionEngine(
      exercise: widget.exercise,
      exerciseName: widget.exercise.displayName(locale),
      profile: _profile,
      calibration: _calibration!,
      weightKg: _weight,
      vlThreshold: settings.vlThreshold,
      autoStopOnVl: settings.autoStopOnVl,
      source: vision,
    );
    final controller = VbtEngineController(
      engine: engine,
      locale: locale,
      voiceEnabled: settings.voiceEnabled,
      onAutoStop: _handleAutoStop,
    );
    setState(() => _controller = controller);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle == null || lifecycle == AppLifecycleState.resumed) {
      controller.start();
    } else {
      vision?.setPaused(true);
    }
  }

  void _pause() {
    _visionSource?.setPaused(true);
    _controller?.pause();
    setState(() {});
  }

  void _resume() {
    _visionSource?.setPaused(false);
    _controller?.resume();
    setState(() {});
  }

  void _handleAutoStop() {
    if (!mounted || _autoStopHandled) return;
    _autoStopHandled = true;
    _pause();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.stop_circle_rounded, color: AppColors.orange),
            const SizedBox(width: 10),
            Text(context.t('autoStopTitle')),
          ],
        ),
        content: Text(context.t('vlWarning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t('reportTitle')),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) _finishSet();
    });
  }

  Future<void> _finishSet() async {
    final controller = _controller;
    if (controller == null || _finishing) return;
    _finishing = true;
    final result = controller.stop();
    _visionSource?.setPaused(true);

    if (result.reps.isEmpty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.t('noReps')),
          content: Text(
            context.isZh
                ? '没有达到有效幅度的动作。结束本组还是继续？'
                : 'No rep met the ROM threshold. Finish or continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.t('resume')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.t('commonFinish')),
            ),
          ],
        ),
      );
      _finishing = false;
      if (!mounted) return;
      if (discard == true) {
        setState(() => _allowPop = true);
        Navigator.of(context).pop();
      } else {
        await _restartSession();
      }
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(workoutRepositoryProvider);
    int? sessionId;
    try {
      sessionId = await repo.saveSession(
        SessionDraft(
          exerciseId: result.exerciseId,
          exerciseName: result.exerciseName,
          tier: result.tier,
          startedAt: result.startedAt,
          finishedAt: result.finishedAt,
          weightKg: _weight,
          plateDiameterCm: result.calibration.plateDiameterCm,
          scaleMetersPerPixel: result.calibration.metersPerPixel,
          totalReps: result.totalReps,
          invalidReps: result.invalidReps,
          avgMeanVelocity: result.avgMeanVelocity,
          bestMeanVelocity: result.bestMeanVelocity,
          peakVelocity: result.peakVelocity,
          bestRomCm: result.bestRomCm,
          velocityLoss: result.velocityLoss,
        ),
        result.reps
            .map(
              (rep) => RepDraft(
                repIndex: rep.index,
                meanVelocity: rep.meanVelocity,
                peakVelocity: rep.peakVelocity,
                romCm: rep.romCm,
                velocityLossPercent: rep.velocityLossPercent,
                durationMs: rep.durationMs,
                eccentricMs: rep.eccentricMs,
                concentricMs: rep.concentricMs,
                minHipAngle: rep.minHipAngle,
                minKneeAngle: rep.minKneeAngle,
                isBestRep: rep.isBestRep,
              ),
            )
            .toList(),
      );
    } catch (_) {
      sessionId = null;
    }

    if (widget.planDay != null && widget.planItemId != null) {
      try {
        final plan = await ref.read(planProvider(widget.planDay!).future);
        final item = plan
            .where((item) => item.id == widget.planItemId)
            .firstOrNull;
        if (item != null) {
          await repo.completePlanSet(
            exerciseId: widget.exercise.id,
            dayKey: widget.planDay!,
            targetSets: item.targetSets,
          );
        }
      } catch (_) {
        // A plan update is non-critical; the set itself is already saved.
      }
    }

    if (!mounted) return;
    final vision = _visionSource;
    _visionSource = null;
    await vision?.stop();
    if (!mounted) return;
    final data = ReportData.fromSetResult(result, saved: sessionId != null);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ReportPage(data: data, sessionId: sessionId),
      ),
    );
  }

  Future<void> _restartSession() async {
    final vision = _visionSource;
    _visionSource = null;
    await vision?.stop();
    if (!mounted) return;
    _controller?.dispose();
    _controller = null;
    _autoStopHandled = false;
    _finishing = false;
    setState(() {});
    await _start();
  }

  Future<void> _flipCamera() async {
    if (_starting || _controller != null || _visionSource != null) {
      showAppSnack(
        context,
        context.isZh
            ? '训练进行中，请先结束本组再切换摄像头'
            : 'Finish the set before switching cameras',
        error: true,
      );
      return;
    }
    await _camera.flip();
    if (_camera.error != null && mounted) {
      showAppSnack(context, context.t('cameraFailed'), error: true);
    }
  }

  Future<void> _toggleCamera() async {
    if (_starting || _controller != null || _visionSource != null) {
      showAppSnack(
        context,
        context.isZh
            ? '训练进行中，请先结束本组再切换相机'
            : 'Finish the set before switching cameras',
        error: true,
      );
      return;
    }
    await _camera.toggle();
    if (_camera.error != null && mounted) {
      showAppSnack(context, context.t('cameraFailed'), error: true);
    }
  }

  Future<void> _confirmLeave() async {
    if (_controller == null) {
      if (mounted) {
        setState(() => _allowPop = true);
        Navigator.of(context).pop();
      }
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.isZh ? '结束本次训练？' : 'Leave this set?'),
        content: Text(
          context.isZh
              ? '当前组尚未保存，返回将丢弃本组数据。'
              : 'This set has not been saved. Leaving discards it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t('commonCancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.t('commonFinish'),
              style: const TextStyle(color: AppColors.orange),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      final vision = _visionSource;
      _visionSource = null;
      await vision?.stop();
      if (!mounted) return;
      _controller?.stop();
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
    }
  }

  Future<void> _editWeight() async {
    final controller = TextEditingController(
      text: _weight > 0 ? formatNumber(_weight) : '',
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('weight')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: 'kg',
            hintText: context.t('weightPlaceholder'),
          ),
          onSubmitted: (text) {
            Navigator.of(context).pop(double.tryParse(text.trim()) ?? 0);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t('commonCancel')),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .pop(double.tryParse(controller.text.trim()) ?? 0),
            child: Text(context.t('commonConfirm')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && mounted) {
      setState(() => _weight = value.clamp(0, 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final stats = controller?.stats;
    final painterFrame = controller?.frame ?? _emptyFrame;
    final media = MediaQuery.of(context);
    final compact = media.size.height < 760;
    final cardWidth = (media.size.width * 0.31).clamp(112.0, 178.0).toDouble();
    final topInset = media.padding.top;

    return PopScope(
      canPop: _allowPop || _controller == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _camera,
          builder: (context, _) {
            return Stack(
              key: _hudKey,
              children: [
                Positioned.fill(
                  child: CameraPreviewLayer(
                    session: _camera,
                    opacity: _visionSource != null ? 1.0 : 0.5,
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: HudPainter(
                      frame: painterFrame,
                      cameraActive: _camera.active,
                    ),
                  ),
                ),
                if (controller != null) ...[
                  Positioned(
                    left: 12,
                    top: topInset + (compact ? 96 : 112),
                    child: SizedBox(
                      width: cardWidth,
                      child: ValueListenableBuilder<LiveStats?>(
                        valueListenable: controller.stats,
                        builder: (context, stats, _) {
                          if (stats == null) return const SizedBox.shrink();
                          return _StatStack(
                            stats: stats,
                            targetReps: widget.targetReps,
                            threshold: ref
                                .read(settingsProvider)
                                .value
                                .vlThreshold,
                            compact: compact,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: topInset + (compact ? 96 : 112),
                    child: ValueListenableBuilder<LiveStats?>(
                      valueListenable: controller.stats,
                      builder: (context, stats, _) {
                        if (stats == null) return const SizedBox.shrink();
                        return _PhaseRail(stats: stats);
                      },
                    ),
                  ),
                  if (stats != null)
                    Positioned(
                      left: cardWidth + 24,
                      right: 12,
                      bottom: 92,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _CueBanner(stats: controller.stats),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: _BottomControls(
                        controller: controller,
                        saving: _saving,
                        onPause: _pause,
                        onResume: _resume,
                        onFinish: _finishSet,
                        onVoice: () {
                          final settings = ref.read(settingsProvider);
                          settings.toggleVoice();
                          controller.setVoiceEnabled(!controller.voiceEnabled);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ] else
                  Positioned.fill(
                    child: _Preflight(
                      exercise: widget.exercise,
                      profile: _profile,
                      targetReps: widget.targetReps,
                      weight: _weight,
                      calibration: _calibration,
                      visionReady:
                          VisionPoseSource.isSupported && _camera.active,
                      onWeightEdit: _editWeight,
                      onWeightStep: (delta) => setState(
                        () => _weight = (_weight + delta).clamp(0, 600),
                      ),
                      onCalibrate: _openCalibration,
                      onQuickCalibrate: _quickCalibrate,
                      onStart: _start,
                    ),
                  ),
                if (controller != null && _visionSource != null)
                  Positioned(
                    top: topInset + 86,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: ValueListenableBuilder<LiveFrame?>(
                          valueListenable: controller.frame,
                          builder: (context, frame, _) {
                            if (frame?.hasPose ?? false) {
                              return const SizedBox.shrink();
                            }
                            final hasError = _visionSource?.lastError != null;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.48),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 9,
                                    height: 9,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.4,
                                      color: hasError
                                          ? AppColors.orange
                                          : AppColors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasError
                                        ? (context.isZh
                                              ? '视觉推理暂不可用'
                                              : 'Vision unavailable')
                                        : (context.isZh
                                              ? '等待人体入镜…'
                                              : 'Waiting for a person…'),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                _TopBar(
                  exercise: widget.exercise,
                  controller: controller,
                  camera: _camera,
                  vision: _visionSource != null,
                  onBack: _confirmLeave,
                  onCamera: _toggleCamera,
                  onFlip: _flipCamera,
                  onInfo: _showDemoInfo,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDemoInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSoft,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.stroke,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.science_outlined, color: AppColors.orange),
                  const SizedBox(width: 10),
                  Text(
                    _visionSource != null
                        ? (context.isZh ? '视觉推理模式' : 'Vision mode')
                        : context.t('demoNoticeTitle'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _visionSource != null
                    ? (context.isZh
                          ? '当前使用 ML Kit Pose Landmarker 从相机实时提取 33 个关键点；躯干/手腕参考点用于 VBT 速度解算，杠铃端面 YOLOv8 检测尚未接入。'
                          : 'ML Kit Pose Landmarker is extracting 33 landmarks from the camera in real time. A body/wrist reference drives VBT velocity; the YOLOv8 barbell detector is not bundled yet.')
                    : context.t('demoNoticeBody'),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _visionSource != null
                    ? (context.isZh
                          ? '当前：ML Kit 姿态推理 · One-Euro 滤波 · 四态重复状态机'
                          : 'Current: ML Kit pose · One-Euro filter · 4-state rep machine')
                    : context.isZh
                    ? '当前：模拟姿态源 · 30 FPS · One-Euro 滤波 · 四态重复状态机'
                    : 'Current: simulated pose · 30 FPS · One-Euro filter · 4-state rep machine',
                style: const TextStyle(fontSize: 10, color: AppColors.dim),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.t('ok')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.exercise,
    required this.controller,
    required this.camera,
    required this.vision,
    required this.onBack,
    required this.onCamera,
    required this.onFlip,
    required this.onInfo,
  });

  final Exercise exercise;
  final VbtEngineController? controller;
  final CameraSession camera;
  final bool vision;
  final VoidCallback onBack;
  final VoidCallback onCamera;
  final VoidCallback onFlip;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Row(
            children: [
              GlassPanel(
                radius: 15,
                blur: 12,
                padding: EdgeInsets.zero,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            exercise.displayName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 8),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        TierBadge(
                          tierValue: exercise.tier.value,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (vision ? AppColors.green : AppColors.orange)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            vision ? 'ML KIT' : context.t('demoBadge'),
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: vision
                                  ? AppColors.green
                                  : AppColors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            vision ? 'ML KIT · ≤15 FPS' : 'AI VISION · 30 FPS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (controller != null)
                ValueListenableBuilder<LiveStats?>(
                  valueListenable: controller!.stats,
                  builder: (context, stats, _) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        '${stats?.elapsed.inSeconds ?? 0}s',
                        style: numericStyle(
                          size: 10,
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              GlassPanel(
                radius: 15,
                blur: 12,
                padding: EdgeInsets.zero,
                child: IconButton(
                  onPressed: onInfo,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GlassPanel(
                radius: 15,
                blur: 12,
                padding: EdgeInsets.zero,
                child: IconButton(
                  tooltip: camera.isFront ? '后置摄像头' : '前置摄像头',
                  onPressed: camera.initializing ? null : onFlip,
                  icon: Icon(
                    camera.isFront
                        ? Icons.camera_front_rounded
                        : Icons.camera_rear_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GlassPanel(
                radius: 15,
                blur: 12,
                padding: EdgeInsets.zero,
                child: IconButton(
                  onPressed: camera.initializing ? null : onCamera,
                  icon: camera.initializing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1.6),
                        )
                      : Icon(
                          camera.active
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          size: 19,
                          color: camera.active ? AppColors.green : Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatStack extends StatelessWidget {
  const _StatStack({
    required this.stats,
    required this.targetReps,
    required this.threshold,
    required this.compact,
  });

  final LiveStats stats;
  final int targetReps;
  final double threshold;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final lossColor = stats.velocityLoss >= threshold
        ? AppColors.orange
        : stats.velocityLoss >= threshold * 0.5
        ? AppColors.yellow
        : AppColors.green;
    return Column(
      children: [
        GlassStatCard(
          label: context.t('reps'),
          value: '${stats.repCount}',
          unit: '/ $targetReps',
          accent: AppColors.green,
          compact: compact,
          secondary: stats.invalidCount > 0
              ? '${context.t('invalidRep')} · ${stats.invalidCount}'
              : context.t('perRep').replaceAll('{n}', '${stats.repCount + 1}'),
        ),
        const SizedBox(height: 7),
        GlassStatCard(
          label: context.t('meanVelocity'),
          value: formatVelocity(stats.meanVelocity),
          unit: 'm/s',
          accent: AppColors.blue,
          compact: compact,
          secondary:
              '${context.t('peakVelocity')} ${formatVelocity(stats.peakVelocity)}',
          progress: clampDouble(stats.currentVelocity / 1.4, 0, 1),
        ),
        const SizedBox(height: 7),
        GlassStatCard(
          label: context.t('rom'),
          value: '${stats.romCm.round()}',
          unit: 'cm',
          accent: AppColors.orange,
          compact: compact,
          secondary:
              '${context.t('kneeAngle')} ${stats.kneeAngle.round()}° · ${context.t('hipAngle')} ${stats.hipAngle.round()}°',
        ),
        const SizedBox(height: 7),
        GlassStatCard(
          label: context.t('velocityLoss'),
          value: stats.velocityLoss.toStringAsFixed(1),
          unit: '%',
          accent: lossColor,
          compact: compact,
          secondary:
              '${stats.eccentricSeconds.toStringAsFixed(1)} : ${stats.concentricSeconds.toStringAsFixed(1)} ${context.t('tempo')}',
          progress: clampDouble(stats.velocityLoss / 40, 0, 1),
          progressMarker: clampDouble(threshold / 40, 0, 1),
        ),
      ],
    );
  }
}

class _PhaseRail extends StatelessWidget {
  const _PhaseRail({required this.stats});

  final LiveStats stats;

  @override
  Widget build(BuildContext context) {
    final phases = [
      (RepPhase.eccentric, AppColors.green, context.t('phaseEccentric')),
      (RepPhase.concentric, AppColors.orange, context.t('phaseConcentric')),
      (RepPhase.completed, AppColors.blue, context.t('phaseCompleted')),
    ];
    return GlassPanel(
      radius: 14,
      blur: 12,
      tint: const Color(0x4D0B1218),
      borderColor: Colors.white.withValues(alpha: 0.09),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < phases.length; index++) ...[
            _PhaseDot(
              active: stats.phase == phases[index].$1,
              color: phases[index].$2,
              label: phases[index].$3,
            ),
            if (index != phases.length - 1)
              Container(
                width: 1,
                height: 14,
                color: Colors.white.withValues(alpha: 0.12),
              ),
          ],
          const SizedBox(height: 10),
          Container(
            width: 20,
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 8),
          Text(
            formatElapsed(stats.elapsed),
            style: numericStyle(
              size: 9,
              color: Colors.white.withValues(alpha: 0.7),
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseDot extends StatelessWidget {
  const _PhaseDot({
    required this.active,
    required this.color,
    required this.label,
  });

  final bool active;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: active ? 9 : 6,
          height: active ? 9 : 6,
          decoration: BoxDecoration(
            color: active ? color : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            color: active ? color : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.controller,
    required this.saving,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onVoice,
  });

  final VbtEngineController controller;
  final bool saving;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 20,
      blur: 20,
      tint: const Color(0xE60B1218),
      borderColor: Colors.white.withValues(alpha: 0.1),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      child: Row(
        children: [
          ValueListenableBuilder<LiveStats?>(
            valueListenable: controller.stats,
            builder: (context, stats, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: controller.running
                              ? AppColors.green
                              : AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatElapsed(stats?.elapsed ?? Duration.zero),
                        style: numericStyle(
                          size: 16,
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.running
                        ? (context.isZh ? '追踪中' : 'TRACKING')
                        : (context.isZh ? '已暂停' : 'PAUSED'),
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: controller.running
                          ? AppColors.green
                          : AppColors.orange,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: onVoice,
            icon: Icon(
              controller.voiceEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: controller.voiceEnabled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
              size: 20,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (controller.running) {
                onPause();
              } else {
                onResume();
              }
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Icon(
                controller.running
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: saving ? null : onFinish,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.background,
                minimumSize: const Size(0, 46),
              ),
              child: saving
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : Text(context.t('finishSet')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Preflight extends StatelessWidget {
  const _Preflight({
    required this.exercise,
    required this.profile,
    required this.targetReps,
    required this.weight,
    required this.calibration,
    required this.visionReady,
    required this.onWeightEdit,
    required this.onWeightStep,
    required this.onCalibrate,
    required this.onQuickCalibrate,
    required this.onStart,
  });

  final Exercise exercise;
  final ExerciseProfile profile;
  final int targetReps;
  final double weight;
  final Calibration? calibration;
  final bool visionReady;
  final VoidCallback onWeightEdit;
  final ValueChanged<double> onWeightStep;
  final VoidCallback onCalibrate;
  final VoidCallback onQuickCalibrate;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final calibrated = calibration != null;
    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: GlassPanel(
              radius: 26,
              blur: 26,
              tint: const Color(0xF20C141B),
              borderColor: Colors.white.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.center_focus_strong_rounded,
                          color: AppColors.green,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              calibrated
                                  ? context.t('readyTitle')
                                  : context.t('calibrationRequired'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              context.t('tier${exercise.tier.value}'),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.dim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TierBadge(tierValue: exercise.tier.value),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exercise.displayName(
                      Localizations.localeOf(context).languageCode,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Column(
                      children: [
                        _SetupRow(
                          icon: Icons.repeat_rounded,
                          label: context.isZh ? '目标次数' : 'Target reps',
                          value: '$targetReps',
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            const Icon(
                              Icons.fitness_center_rounded,
                              size: 15,
                              color: AppColors.dim,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              context.t('weight'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            const Spacer(),
                            _StepButton(
                              icon: Icons.remove_rounded,
                              onTap: () => onWeightStep(-2.5),
                            ),
                            GestureDetector(
                              onTap: onWeightEdit,
                              child: SizedBox(
                                width: 58,
                                child: Text(
                                  weight > 0
                                      ? '${formatNumber(weight)} kg'
                                      : context.t('bodyweight'),
                                  textAlign: TextAlign.center,
                                  style: numericStyle(
                                    size: 13,
                                    color: Colors.white,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            _StepButton(
                              icon: Icons.add_rounded,
                              onTap: () => onWeightStep(2.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            const Icon(
                              Icons.straighten_rounded,
                              size: 15,
                              color: AppColors.dim,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              context.t('targetRom'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${profile.minRomCm.round()} cm',
                              style: numericStyle(
                                size: 12,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: onCalibrate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: calibrated
                            ? AppColors.green.withValues(alpha: 0.07)
                            : AppColors.orange.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: calibrated
                              ? AppColors.green.withValues(alpha: 0.22)
                              : AppColors.orange.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            calibrated
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: calibrated
                                ? AppColors.green
                                : AppColors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              calibrated
                                  ? '${context.t('calibrated')} · '
                                        '${calibration!.plateDiameterCm.round()} cm · '
                                        'k ${calibration!.metersPerPixel.toStringAsFixed(5)}'
                                  : context.t('calibrationBody'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                height: 1.45,
                                color: calibrated
                                    ? AppColors.muted
                                    : AppColors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            calibrated
                                ? context.t('recalibrate')
                                : context.t('tapToCalibrate'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: calibrated
                                  ? AppColors.green
                                  : AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!calibrated) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onQuickCalibrate,
                        child: Text(
                          context.t('quickCalibrate'),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  GradientButton(
                    label: calibrated
                        ? context.t('startSet')
                        : context.t('tapToCalibrate'),
                    icon: calibrated
                        ? Icons.play_arrow_rounded
                        : Icons.center_focus_strong_rounded,
                    onPressed: onStart,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    visionReady
                        ? (context.isZh
                              ? '相机已就绪：开始后运行 ML Kit 姿态推理，请保持全身与器械入镜。'
                              : 'Camera ready: ML Kit pose inference starts with the set. Keep your body and equipment in frame.')
                        : context.t('demoNoticeBody'),
                    style: const TextStyle(
                      fontSize: 8.5,
                      height: 1.5,
                      color: AppColors.dim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.dim),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const Spacer(),
        Text(
          value,
          style: numericStyle(
            size: 13,
            color: Colors.white,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 15, color: AppColors.muted),
      ),
    );
  }
}

class _CueBanner extends StatefulWidget {
  const _CueBanner({required this.stats});

  final ValueNotifier<LiveStats?> stats;

  @override
  State<_CueBanner> createState() => _CueBannerState();
}

class _CueBannerState extends State<_CueBanner> {
  String? _message;
  int _serial = -1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.stats.addListener(_onStats);
    _onStats();
  }

  @override
  void dispose() {
    widget.stats.removeListener(_onStats);
    _timer?.cancel();
    super.dispose();
  }

  void _onStats() {
    final stats = widget.stats.value;
    if (stats == null || stats.cueSerial == _serial) return;
    _serial = stats.cueSerial;
    final cue = stats.cue;
    if (cue == null) return;
    setState(() => _message = cue);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2100), () {
      if (mounted) setState(() => _message = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      offset: message == null ? const Offset(0, 0.4) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: message == null ? 0 : 1,
        child: message == null
            ? const SizedBox.shrink()
            : GlassPanel(
                radius: 30,
                blur: 14,
                tint: const Color(0xE60B1218),
                borderColor: AppColors.orange.withValues(alpha: 0.25),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      switch (message) {
                        'newBest' => Icons.star_rounded,
                        'invalidRep' => Icons.warning_amber_rounded,
                        'vlWarning' ||
                        'autoStopTitle' => Icons.stop_circle_rounded,
                        _ => Icons.keyboard_arrow_down_rounded,
                      },
                      size: 15,
                      color: message == 'newBest'
                          ? AppColors.green
                          : AppColors.orange,
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        context.t(message),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
