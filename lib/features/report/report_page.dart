import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../shell/home_shell.dart';
import 'report_data.dart';
import 'share_service.dart';
import 'widgets/velocity_chart.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key, this.data, this.sessionId});

  final ReportData? data;
  final int? sessionId;

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final GlobalKey _shareKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.data != null) {
      return _buildScaffold(context, widget.data!);
    }
    final sessionId = widget.sessionId;
    if (sessionId == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final async = ref.watch(sessionDetailProvider(sessionId));
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => _errorScaffold(context, '$error'),
      data: (detail) {
        if (detail == null) {
          return _errorScaffold(context, context.t('historyEmpty'));
        }
        return _buildScaffold(context, ReportData.fromSessionDetail(detail));
      },
    );
  }

  Widget _errorScaffold(BuildContext context, String message) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: context.t('errorGeneric'),
            body: message,
            actionLabel: context.t('commonBack'),
            onAction: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ReportData data) {
    final locale = Localizations.localeOf(context).languageCode;
    final threshold = ref.watch(settingsProvider).value.vlThreshold;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded, size: 22),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t('reportTitle'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${formatDate(data.startedAt)} · ${formatTime(data.startedAt)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.dim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data.saved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.t('saved'),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      onPressed: () => _share(context, data, locale),
                      icon: const Icon(Icons.ios_share_rounded, size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  child: RepaintBoundary(
                    key: _shareKey,
                    child: Container(
                      color: AppColors.background,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryCard(data: data, locale: locale),
                          const SizedBox(height: 14),
                          _VelocityCard(data: data, threshold: threshold),
                          const SizedBox(height: 14),
                          _MetricGrid(data: data),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                context.t('repDetail'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              Text(
                                '${data.reps.length} ${context.t('reps')}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.dim,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (data.reps.isEmpty)
                            SurfaceCard(
                              child: Text(
                                context.t('noReps'),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          else
                            ...data.reps.reversed.map(
                              (rep) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _RepRow(rep: rep),
                              ),
                            ),
                          if (data.invalidReps > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.orange.withValues(
                                    alpha: 0.18,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 15,
                                    color: AppColors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${data.invalidReps} ${context.t('invalidRepsNote')}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 26),
                          Center(
                            child: Column(
                              children: [
                                const AppLogoMark(size: 26),
                                const SizedBox(height: 8),
                                Text(
                                  'FORCETRACE · VBT REPORT',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    color: AppColors.dim.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _share(context, data, locale),
                  icon: const Icon(Icons.ios_share_rounded, size: 17),
                  label: Text(context.t('share')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (widget.data != null) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(context.t('commonDone')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(
    BuildContext context,
    ReportData data,
    String locale,
  ) async {
    final ok = await shareReportImage(
      boundaryKey: _shareKey,
      data: data,
      locale: locale,
    );
    if (!ok && context.mounted) {
      showAppSnack(context, context.t('shareFailed'), error: true);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.locale});

  final ReportData data;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final tierColor = switch (data.tier) {
      1 => AppColors.green,
      2 => AppColors.blue,
      _ => AppColors.orange,
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17261D), Color(0xFF101820)],
        ),
        border: Border.all(color: tierColor.withValues(alpha: 0.22)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TierBadge(tierValue: data.tier),
              const Spacer(),
              Text(
                locale == 'zh' ? '组后总结' : 'SET SUMMARY',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: AppColors.dim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.exerciseName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.2,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BEST MEAN V',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.dim,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatVelocity(data.bestMeanVelocity),
                        style: numericStyle(
                          size: 44,
                          color: AppColors.green,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'm/s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              _VlBadge(loss: data.velocityLoss),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeadStat(
                label: context.t('totalReps'),
                value: '${data.totalReps}',
                unit: context.t('repsShort'),
              ),
              _divider(),
              _HeadStat(
                label: context.t('peakVelocity'),
                value: formatVelocity(data.peakVelocity),
                unit: 'm/s',
              ),
              _divider(),
              _HeadStat(
                label: context.t('bestRom'),
                value: '${data.bestRomCm.round()}',
                unit: 'cm',
              ),
              const Spacer(),
              if (data.weightKg > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${formatNumber(data.weightKg)} kg',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 24,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: Colors.white.withValues(alpha: 0.07),
  );
}

class _HeadStat extends StatelessWidget {
  const _HeadStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.dim)),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: numericStyle(size: 16)),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(fontSize: 7.5, color: AppColors.dim),
            ),
          ],
        ),
      ],
    );
  }
}

class _VlBadge extends StatelessWidget {
  const _VlBadge({required this.loss});

  final double loss;

  @override
  Widget build(BuildContext context) {
    final color = loss >= 20
        ? AppColors.orange
        : loss >= 10
        ? AppColors.yellow
        : AppColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.t('velocityLoss').toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: color.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${loss.toStringAsFixed(1)}%',
            style: numericStyle(size: 22, color: color),
          ),
        ],
      ),
    );
  }
}

class _VelocityCard extends StatelessWidget {
  const _VelocityCard({required this.data, required this.threshold});

  final ReportData data;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.t('perRepVelocity'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              const _LegendDot(color: AppColors.green, label: 'Best'),
              const SizedBox(width: 8),
              const _LegendDot(color: AppColors.blue, label: 'Mean V'),
              const SizedBox(width: 8),
              const _LegendDot(color: AppColors.orange, label: 'VL'),
            ],
          ),
          const SizedBox(height: 16),
          VelocityChart(reps: data.reps, threshold: threshold),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 8, color: AppColors.dim)),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final avgTempo = data.reps.isEmpty
        ? 0.0
        : data.reps
                  .map(
                    (r) => r.concentricMs == 0
                        ? 0.0
                        : r.eccentricMs / r.concentricMs,
                  )
                  .reduce((a, b) => a + b) /
              data.reps.length;
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: context.t('avgMean'),
            value: formatVelocity(data.avgMeanVelocity),
            unit: 'm/s',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: context.t('duration'),
            value: formatElapsed(data.duration),
            unit: '',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: context.t('tempo'),
            value: avgTempo == 0 ? '—' : avgTempo.toStringAsFixed(1),
            unit: ': 1',
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.strokeSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: AppColors.dim),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: numericStyle(size: 18),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 7.5, color: AppColors.dim),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RepRow extends StatelessWidget {
  const _RepRow({required this.rep});

  final RepReport rep;

  @override
  Widget build(BuildContext context) {
    final color = rep.isBestRep
        ? AppColors.green
        : rep.velocityLoss >= 20
        ? AppColors.orange
        : AppColors.blue;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: rep.isBestRep
              ? AppColors.green.withValues(alpha: 0.28)
              : AppColors.strokeSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: Text(
              '${rep.index}',
              style: numericStyle(size: 12, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatVelocity(rep.meanVelocity),
                    style: numericStyle(size: 17),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'm/s',
                    style: TextStyle(fontSize: 8, color: AppColors.dim),
                  ),
                  if (rep.isBestRep) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.green,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${context.t('peakVelocity')} ${formatVelocity(rep.peakVelocity)} · ROM ${rep.romCm.round()}cm · ${rep.tempo}s',
                style: const TextStyle(fontSize: 8.5, color: AppColors.dim),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'VL ${rep.velocityLoss.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDuration(rep.durationMs),
                style: const TextStyle(fontSize: 8.5, color: AppColors.dim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
