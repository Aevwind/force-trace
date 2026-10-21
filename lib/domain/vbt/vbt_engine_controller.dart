import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'pose_models.dart';
import 'vbt_session_engine.dart';

/// Owns the 30 Hz timer around [VbtSessionEngine] and publishes immutable
/// frames/statistics to the HUD. Keeping Riverpod out of the hot path avoids
/// rebuilding the whole widget tree on every camera frame.
class VbtEngineController {
  VbtEngineController({
    required this.engine,
    required this.locale,
    required this.voiceEnabled,
    this.onAutoStop,
  }) : voice = VoiceCoach(locale: locale);

  final VbtSessionEngine engine;
  final String locale;
  bool voiceEnabled;
  final VoidCallback? onAutoStop;
  final VoiceCoach voice;

  final ValueNotifier<LiveFrame?> frame = ValueNotifier(null);
  final ValueNotifier<LiveStats?> stats = ValueNotifier(null);

  Timer? _timer;
  bool _running = false;
  bool _disposed = false;

  bool get running => _running;
  bool get autoStopped => engine.autoStopped;

  void start() {
    if (_disposed || _running) return;
    _running = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) => _tick());
  }

  void pause() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    engine.resetTracking();
    stats.value = engine.lastStats;
  }

  void resume() => start();

  void setVoiceEnabled(bool value) => voiceEnabled = value;

  void _tick() {
    if (_disposed || !_running) return;
    engine.advance(0.033);
    frame.value = engine.lastFrame;
    stats.value = engine.lastStats;
    final events = engine.takeEvents();
    if (events.isNotEmpty) {
      for (final event in events) {
        if (event.kind == VbtEventKind.rep) {
          HapticFeedback.mediumImpact().ignore();
        }
        if (voiceEnabled) {
          voice.speak(_voiceText(event));
        }
      }
    }
    if (engine.autoStopped) {
      pause();
      onAutoStop?.call();
    }
  }

  SetResult stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    return engine.finish();
  }

  String _voiceText(VbtEvent event) {
    final zh = locale == 'zh';
    return switch (event.kind) {
      VbtEventKind.rep =>
        zh ? '第 ${event.repIndex} 次' : 'Rep ${event.repIndex}',
      VbtEventKind.invalidRep =>
        zh ? '幅度不足，不计次数' : 'Range too short, not counted',
      VbtEventKind.bestRep => zh ? '新的最快速度' : 'New best velocity',
      VbtEventKind.depth => zh ? '再蹲深一点' : 'Go a little deeper',
      VbtEventKind.velocityLoss =>
        zh
            ? '速度损失 ${event.value.round()}%，建议停组'
            : 'Velocity loss ${event.value.round()} percent, stop the set',
      VbtEventKind.autoStop => zh ? '已自动停组' : 'Set stopped automatically',
    };
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    unawaited(voice.dispose());
    frame.dispose();
    stats.dispose();
  }
}

class VoiceCoach {
  VoiceCoach({required this.locale});

  final String locale;

  FlutterTts? _tts;
  bool _failed = false;

  Future<FlutterTts?> _ensure() async {
    if (_failed) return null;
    final existing = _tts;
    if (existing != null) return existing;
    try {
      final tts = FlutterTts();
      await tts.setLanguage(locale == 'zh' ? 'zh-CN' : 'en-US');
      await tts.setSpeechRate(0.5);
      await tts.setVolume(0.9);
      await tts.setPitch(1.0);
      _tts = tts;
      return tts;
    } catch (_) {
      _failed = true;
      return null;
    }
  }

  Future<void> speak(String text) async {
    final tts = await _ensure();
    if (tts == null) return;
    try {
      await tts.stop();
      await tts.speak(text);
    } catch (_) {
      _failed = true;
    }
  }

  Future<void> dispose() async {
    try {
      await _tts?.stop();
    } catch (_) {
      // TTS is best-effort; failures should never break a set.
    }
    _tts = null;
  }
}
