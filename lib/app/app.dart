import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/common.dart';
import '../features/shell/home_shell.dart';

class ForceTraceApp extends ConsumerWidget {
  const ForceTraceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    return MaterialApp(
      title: 'ForceTrace · 力迹',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: Locale(settings.locale),
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.15,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _BootstrapGate(),
    );
  }
}

class _BootstrapGate extends ConsumerWidget {
  const _BootstrapGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);
    return bootstrap.when(
      loading: () => const BootstrapScreen(),
      error: (error, stack) => _BootstrapError(
        error: error,
        onRetry: () => ref.invalidate(bootstrapProvider),
      ),
      data: (_) => const HomeShell(),
    );
  }
}

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        grid: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(112, 76),
                    painter: _LogoPainter(progress: _controller.value),
                  );
                },
              ),
              const SizedBox(height: 26),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFF9BE7B8)],
                ).createShader(bounds),
                child: const Text(
                  'FORCETRACE',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '力迹 · AI 视觉 VBT 训练教练',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 190,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppColors.strokeSoft,
                    valueColor: AlwaysStoppedAnimation(AppColors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '正在载入 1,324 个动作 · 10 种语言',
                style: TextStyle(fontSize: 11.5, color: AppColors.dim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bar = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(14, center.dy),
      Offset(size.width - 14, center.dy),
      bar,
    );

    final plate = Paint()..color = AppColors.green;
    for (final dx in [26.0, 36.0, size.width - 36, size.width - 26]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(dx, center.dy), width: 5, height: 34),
          const Radius.circular(2.5),
        ),
        plate,
      );
    }

    final trace = Path();
    final startX = 18.0 + (size.width - 36) * progress;
    trace.moveTo(18, center.dy);
    trace.lineTo(startX - 12, center.dy);
    trace.lineTo(startX - 6, center.dy - 10);
    trace.lineTo(startX, center.dy + 10);
    trace.lineTo(startX + 6, center.dy - 16);
    trace.lineTo(startX + 12, center.dy);
    trace.lineTo(size.width - 18, center.dy);
    canvas.drawPath(
      trace,
      Paint()
        ..color = AppColors.orange
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(startX, center.dy),
      4,
      Paint()..color = AppColors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.storage_rounded,
                    size: 42,
                    color: AppColors.orange,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '初始化失败',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '本地数据库初始化失败。请确认浏览器支持 WASM，或重启应用后重试。',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.strokeSoft),
                    ),
                    child: Text(
                      '$error',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.dim,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: '重试',
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                    expanded: false,
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
