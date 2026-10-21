import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/vbt/pose_models.dart';

/// Full-screen AR layer: gym stage, body silhouette, trajectory, skeleton,
/// joint angle sectors, barbell plate and the follow-cam speed capsule.
class HudPainter extends CustomPainter {
  HudPainter({required this.frame, required this.cameraActive})
    : super(repaint: frame);

  final ValueListenable<LiveFrame?> frame;
  final bool cameraActive;

  @override
  void paint(Canvas canvas, Size size) {
    final live = frame.value;
    final stage = stageRectFor(size);
    _paintBackdrop(canvas, size, stage);
    if (live == null) {
      _paintCornerBrackets(canvas, stage);
      return;
    }

    Offset toStage(Offset point) {
      if (live.cameraFrame &&
          live.imageSize.width > 1 &&
          live.imageSize.height > 1) {
        // Match CameraPreviewView's BoxFit.cover transform so landmarks sit on
        // the actual body instead of the synthetic square stage.
        final scale = math.max(
          size.width / live.imageSize.width,
          size.height / live.imageSize.height,
        );
        final drawWidth = live.imageSize.width * scale;
        final drawHeight = live.imageSize.height * scale;
        final dx = (size.width - drawWidth) / 2;
        final dy = (size.height - drawHeight) / 2;
        return Offset(point.dx * drawWidth + dx, point.dy * drawHeight + dy);
      }
      return Offset(
        stage.left + point.dx * stage.width,
        stage.top + point.dy * stage.height,
      );
    }

    if (!live.cameraFrame) {
      _paintEquipment(canvas, stage, live.pattern);
      _paintBodySilhouette(canvas, stage, live, toStage);
    }
    _paintTrajectory(canvas, stage, live, toStage);
    _paintSecondarySkeleton(canvas, live, toStage);
    _paintSkeleton(canvas, stage, live, toStage);
    _paintBarbell(canvas, stage, live, toStage);
    _paintCornerBrackets(canvas, stage);
  }

  Rect stageRectFor(Size size) {
    final side = math.min(size.width, size.height * 0.82);
    return Rect.fromLTWH(
      (size.width - side) / 2,
      (size.height - side) / 2,
      side,
      side,
    );
  }

  void _paintBackdrop(Canvas canvas, Size size, Rect stage) {
    if (!cameraActive) {
      final background = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101A22), Color(0xFF060A0E)],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, background);

      final spotlight = Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.055),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(
                  stage.center.dx,
                  stage.top + stage.height * 0.22,
                ),
                radius: stage.width * 0.7,
              ),
            );
      canvas.drawRect(stage, spotlight);

      final floor = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.green.withValues(alpha: 0.035),
              ],
            ).createShader(
              Rect.fromLTWH(
                stage.left,
                stage.top + stage.height * 0.72,
                stage.width,
                stage.height * 0.3,
              ),
            );
      canvas.drawRect(
        Rect.fromLTWH(
          stage.left,
          stage.top + stage.height * 0.72,
          stage.width,
          stage.height * 0.3,
        ),
        floor,
      );

      final grid = Paint()
        ..color = Colors.white.withValues(alpha: 0.022)
        ..strokeWidth = 1;
      for (var x = stage.left; x <= stage.right; x += stage.width / 12) {
        canvas.drawLine(Offset(x, stage.top), Offset(x, stage.bottom), grid);
      }
      for (var y = stage.top; y <= stage.bottom; y += stage.height / 12) {
        canvas.drawLine(Offset(stage.left, y), Offset(stage.right, y), grid);
      }
    } else {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.30),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.30),
            ],
            stops: const [0, 0.22, 0.72, 1],
          ).createShader(Offset.zero & size),
      );
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 0.85,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.18)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);

    // Slow scanline for the AR feel.
    final time = DateTime.now().millisecondsSinceEpoch % 7000 / 7000;
    final scanY = stage.top + stage.height * time;
    canvas.drawRect(
      Rect.fromLTWH(stage.left, scanY, stage.width, 1.2),
      Paint()..color = AppColors.green.withValues(alpha: 0.08),
    );
  }

  void _paintEquipment(Canvas canvas, Rect stage, MotionPattern pattern) {
    final ink = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    switch (pattern) {
      case MotionPattern.bench:
        final benchTop = stage.top + stage.height * 0.63;
        final bench = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            stage.left + stage.width * 0.22,
            benchTop,
            stage.width * 0.48,
            stage.height * 0.035,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(
          bench,
          Paint()..color = Colors.white.withValues(alpha: 0.045),
        );
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.29,
            benchTop + stage.height * 0.035,
          ),
          Offset(
            stage.left + stage.width * 0.29,
            stage.top + stage.height * 0.79,
          ),
          ink,
        );
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.63,
            benchTop + stage.height * 0.035,
          ),
          Offset(
            stage.left + stage.width * 0.63,
            stage.top + stage.height * 0.79,
          ),
          ink,
        );
        break;
      case MotionPattern.pullup:
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.3,
            stage.top + stage.height * 0.16,
          ),
          Offset(
            stage.left + stage.width * 0.8,
            stage.top + stage.height * 0.16,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.18)
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.3,
            stage.top + stage.height * 0.16,
          ),
          Offset(
            stage.left + stage.width * 0.3,
            stage.top + stage.height * 0.08,
          ),
          ink,
        );
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.8,
            stage.top + stage.height * 0.16,
          ),
          Offset(
            stage.left + stage.width * 0.8,
            stage.top + stage.height * 0.08,
          ),
          ink,
        );
        break;
      default:
        // Power rack silhouette behind the athlete.
        final rack = Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 4;
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.14,
            stage.top + stage.height * 0.1,
          ),
          Offset(
            stage.left + stage.width * 0.14,
            stage.top + stage.height * 0.92,
          ),
          rack,
        );
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.86,
            stage.top + stage.height * 0.1,
          ),
          Offset(
            stage.left + stage.width * 0.86,
            stage.top + stage.height * 0.92,
          ),
          rack,
        );
        canvas.drawLine(
          Offset(
            stage.left + stage.width * 0.12,
            stage.top + stage.height * 0.12,
          ),
          Offset(
            stage.left + stage.width * 0.88,
            stage.top + stage.height * 0.12,
          ),
          rack,
        );
        // Plates resting on the floor.
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(
              stage.left + stage.width * (0.84 - i * 0.055),
              stage.top + stage.height * 0.9,
            ),
            stage.width * 0.045,
            Paint()..color = Colors.white.withValues(alpha: 0.035),
          );
        }
        break;
    }

    // Floor line.
    canvas.drawLine(
      Offset(stage.left, stage.top + stage.height * 0.9),
      Offset(stage.right, stage.top + stage.height * 0.9),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.07)
        ..strokeWidth = 1,
    );
  }

  void _paintBodySilhouette(
    Canvas canvas,
    Rect stage,
    LiveFrame live,
    Offset Function(Offset) toStage,
  ) {
    final shoulder = live.landmarks[LandmarkId.shoulder];
    final hip = live.landmarks[LandmarkId.hip];
    final knee = live.landmarks[LandmarkId.knee];
    final ankle = live.landmarks[LandmarkId.ankle];
    if (shoulder == null || hip == null || knee == null || ankle == null) {
      return;
    }
    final points = [
      toStage(shoulder),
      toStage(hip),
      toStage(knee),
      toStage(ankle),
    ];
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = stage.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);

    final head = live.landmarks[LandmarkId.head];
    if (head != null) {
      final headPoint = toStage(head);
      canvas.drawCircle(
        headPoint,
        stage.width * 0.032,
        Paint()..color = Colors.white.withValues(alpha: 0.045),
      );
      canvas.drawLine(
        toStage(shoulder),
        headPoint,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.04)
          ..strokeWidth = stage.width * 0.04
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintTrajectory(
    Canvas canvas,
    Rect stage,
    LiveFrame live,
    Offset Function(Offset) toStage,
  ) {
    if (live.ghostTrajectory.length > 1) {
      _drawSmoothPath(
        canvas,
        live.ghostTrajectory.map((p) => toStage(p.point)).toList(),
        Colors.white.withValues(alpha: 0.09),
        1.6,
      );
    }
    if (live.trajectory.length < 2) return;

    final eccentric = <Offset>[];
    final concentric = <Offset>[];
    for (final point in live.trajectory) {
      final mapped = toStage(point.point);
      if (point.phase == RepPhase.concentric) {
        if (eccentric.isNotEmpty && concentric.isEmpty) {
          concentric.add(eccentric.last);
        }
        concentric.add(mapped);
      } else {
        eccentric.add(mapped);
      }
    }

    for (final segment in [
      (eccentric, AppColors.green),
      (concentric, AppColors.orange),
    ]) {
      if (segment.$1.length < 2) continue;
      _drawSmoothPath(
        canvas,
        segment.$1,
        segment.$2.withValues(alpha: 0.18),
        7,
      );
      _drawSmoothPath(canvas, segment.$1, segment.$2, 2.4);
    }

    final tip = toStage(live.trajectory.last.point);
    canvas.drawCircle(
      tip,
      3.2,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  void _drawSmoothPath(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double width,
  ) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      path.quadraticBezierTo(
        current.dx,
        current.dy,
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
    }
    final last = points.last;
    path.lineTo(last.dx, last.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintSecondarySkeleton(
    Canvas canvas,
    LiveFrame live,
    Offset Function(Offset) toStage,
  ) {
    final m = live.secondaryLandmarks;
    if (m.isEmpty) return;
    final shoulder = m[LandmarkId.shoulder];
    final hip = m[LandmarkId.hip];
    final knee = m[LandmarkId.knee];
    final ankle = m[LandmarkId.ankle];
    if (shoulder == null || hip == null || knee == null || ankle == null) {
      return;
    }
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    void segment(Offset a, Offset b) => canvas.drawLine(a, b, line);

    final s = toStage(shoulder);
    final h = toStage(hip);
    final k = toStage(knee);
    final a = toStage(ankle);
    segment(s, h);
    segment(h, k);
    segment(k, a);
    final elbow = m[LandmarkId.elbow];
    final wrist = m[LandmarkId.wrist];
    if (elbow != null && wrist != null) {
      segment(s, toStage(elbow));
      segment(toStage(elbow), toStage(wrist));
    }
    final head = m[LandmarkId.head];
    if (head != null) segment(s, toStage(head));

    final anchor = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final point in [s, h, k, a]) {
      canvas.drawCircle(point, 2.6, anchor);
    }
  }

  void _paintSkeleton(
    Canvas canvas,
    Rect stage,
    LiveFrame live,
    Offset Function(Offset) toStage,
  ) {
    final shoulder = live.landmarks[LandmarkId.shoulder];
    final hip = live.landmarks[LandmarkId.hip];
    final knee = live.landmarks[LandmarkId.knee];
    final ankle = live.landmarks[LandmarkId.ankle];
    final elbow = live.landmarks[LandmarkId.elbow];
    final wrist = live.landmarks[LandmarkId.wrist];
    final head = live.landmarks[LandmarkId.head];
    if (shoulder == null || hip == null || knee == null || ankle == null) {
      return;
    }
    final s = toStage(shoulder);
    final h = toStage(hip);
    final k = toStage(knee);
    final a = toStage(ankle);

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.94)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    final glow = Paint()
      ..color = AppColors.green.withValues(alpha: 0.08)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    void segment(Offset from, Offset to) {
      canvas.drawLine(from, to, shadow);
      canvas.drawLine(from, to, glow);
      canvas.drawLine(from, to, line);
    }

    segment(s, h);
    segment(h, k);
    segment(k, a);

    if (elbow != null && wrist != null) {
      segment(s, toStage(elbow));
      segment(toStage(elbow), toStage(wrist));
    }
    if (head != null) {
      segment(s, toStage(head));
    }

    _drawAngleSector(
      canvas,
      h,
      s,
      k,
      AppColors.green,
      '${live.hipAngle.round()}°',
    );
    _drawAngleSector(
      canvas,
      k,
      h,
      a,
      AppColors.orange,
      '${live.kneeAngle.round()}°',
    );

    for (final point in [s, h, k, a]) {
      _drawAnchor(canvas, point, stage);
    }
    if (wrist != null) {
      _drawAnchor(canvas, toStage(wrist), stage, radius: 4.5);
    }
  }

  void _drawAngleSector(
    Canvas canvas,
    Offset center,
    Offset a,
    Offset b,
    Color color,
    String label,
  ) {
    final start = math.atan2(a.dy - center.dy, a.dx - center.dx);
    final end = math.atan2(b.dy - center.dy, b.dx - center.dx);
    var sweep = end - start;
    while (sweep > math.pi) {
      sweep -= math.pi * 2;
    }
    while (sweep < -math.pi) {
      sweep += math.pi * 2;
    }
    final radius = 24.0;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      start,
      sweep,
      true,
      Paint()..color = color.withValues(alpha: 0.13),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final middle = start + sweep / 2;
    final labelCenter =
        center + Offset(math.cos(middle), math.sin(middle)) * (radius + 18);
    _text(
      canvas,
      label,
      labelCenter,
      size: 11,
      color: color,
      weight: FontWeight.w800,
      align: TextAlign.center,
      center: true,
    );
  }

  void _drawAnchor(
    Canvas canvas,
    Offset point,
    Rect stage, {
    double radius = 7,
  }) {
    canvas.drawCircle(
      point,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      point,
      radius - 2,
      Paint()..color = const Color(0xFF0A1117).withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      point,
      1.5,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  void _paintBarbell(
    Canvas canvas,
    Rect stage,
    LiveFrame live,
    Offset Function(Offset) toStage,
  ) {
    final bar = toStage(live.bar);
    final plateRadius = stage.width * 0.055;

    if (live.showBarbell) {
      canvas.drawCircle(
        bar + const Offset(0, 4),
        plateRadius,
        Paint()..color = Colors.black.withValues(alpha: 0.3),
      );
      canvas.drawCircle(
        bar,
        plateRadius,
        Paint()..color = const Color(0xFF0C141B).withValues(alpha: 0.92),
      );
      canvas.drawCircle(
        bar,
        plateRadius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.82)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        bar,
        plateRadius * 0.62,
        Paint()
          ..color = AppColors.orange.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawCircle(
        bar,
        plateRadius * 0.18,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
      // Bar sleeve extending behind the plate.
      canvas.drawLine(
        bar,
        bar + Offset(plateRadius * 2.2, 0),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    } else {
      final pulse =
          0.5 + 0.5 * math.sin(DateTime.now().millisecondsSinceEpoch / 240);
      canvas.drawCircle(
        bar,
        plateRadius * (0.55 + pulse * 0.12),
        Paint()
          ..color = AppColors.blue.withValues(alpha: 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        bar,
        5,
        Paint()..color = AppColors.blue.withValues(alpha: 0.85),
      );
    }

    _paintSpeedCapsule(canvas, stage, bar, live.velocity);
  }

  void _paintSpeedCapsule(
    Canvas canvas,
    Rect stage,
    Offset bar,
    double velocity,
  ) {
    const width = 104.0;
    const height = 36.0;
    final left = (bar.dx - width / 2)
        .clamp(stage.left + 6, stage.right - width - 6)
        .toDouble();
    final top = (bar.dy - 60 - height / 2)
        .clamp(stage.top + 6, stage.bottom - height - 6)
        .toDouble();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xCC0B1218));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final color = velocity > 0.45
        ? AppColors.green
        : velocity > 0.18
        ? AppColors.orange
        : AppColors.muted;
    _text(
      canvas,
      velocity.toStringAsFixed(2),
      Offset(left + 12, top + 7),
      size: 17,
      color: color,
      weight: FontWeight.w800,
      numeric: true,
    );
    _text(
      canvas,
      'm/s',
      Offset(left + 58, top + 14),
      size: 8.5,
      color: AppColors.muted,
      weight: FontWeight.w600,
    );
    canvas.drawCircle(
      Offset(left + width - 13, top + height / 2),
      3,
      Paint()..color = color.withValues(alpha: 0.9),
    );
  }

  void _paintCornerBrackets(Canvas canvas, Rect stage) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const length = 22.0;
    final r = stage.deflate(10);
    final corners = [
      (r.topLeft, const Offset(1, 0), const Offset(0, 1)),
      (r.topRight, const Offset(-1, 0), const Offset(0, 1)),
      (r.bottomLeft, const Offset(1, 0), const Offset(0, -1)),
      (r.bottomRight, const Offset(-1, 0), const Offset(0, -1)),
    ];
    for (final corner in corners) {
      canvas.drawLine(corner.$1, corner.$1 + corner.$2 * length, paint);
      canvas.drawLine(corner.$1, corner.$1 + corner.$3 * length, paint);
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset position, {
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w600,
    TextAlign align = TextAlign.left,
    bool center = false,
    bool numeric = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: numeric ? -0.4 : 0,
          fontFeatures: numeric
              ? const [ui.FontFeature.tabularFigures()]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    final offset = center
        ? position - Offset(painter.width / 2, painter.height / 2)
        : position;
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant HudPainter oldDelegate) {
    return oldDelegate.cameraActive != cameraActive ||
        oldDelegate.frame != frame;
  }
}
