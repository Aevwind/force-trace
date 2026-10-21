import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import 'report_data.dart';

Future<bool> shareReportImage({
  required GlobalKey boundaryKey,
  required ReportData data,
  required String locale,
}) async {
  final text = locale == 'zh'
      ? 'ForceTrace 组后报告 · ${data.exerciseName} · ${data.totalReps} 次 · 最佳 ${data.bestMeanVelocity.toStringAsFixed(2)} m/s · 速度损失 ${data.velocityLoss.toStringAsFixed(1)}%'
      : 'ForceTrace set report · ${data.exerciseName} · ${data.totalReps} reps · best ${data.bestMeanVelocity.toStringAsFixed(2)} m/s · VL ${data.velocityLoss.toStringAsFixed(1)}%';

  Uint8List? png;
  try {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is RenderRepaintBoundary) {
      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 32));
      }
      final image = await boundary.toImage(pixelRatio: 2.4);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      png = byteData?.buffer.asUint8List();
    }
  } catch (_) {
    png = null;
  }

  try {
    if (png != null) {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              png,
              mimeType: 'image/png',
              name: 'force-trace-report.png',
            ),
          ],
          text: text,
          subject: 'ForceTrace · ${data.exerciseName}',
        ),
      );
      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed;
    }
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'ForceTrace · ${data.exerciseName}'),
    );
    return true;
  } catch (_) {
    return false;
  }
}
