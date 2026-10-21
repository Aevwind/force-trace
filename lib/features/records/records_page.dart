import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';
import '../report/report_page.dart';
import '../shell/home_shell.dart';

class RecordsPage extends ConsumerStatefulWidget {
  const RecordsPage({super.key});

  @override
  ConsumerState<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends ConsumerState<RecordsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final logsAsync = ref.watch(setLogsProvider);
    final sessions = sessionsAsync.valueOrNull ?? const <SessionSummary>[];
    final logs = logsAsync.valueOrNull ?? const <SetLog>[];

    final totalReps =
        sessions.fold<int>(0, (sum, s) => sum + s.totalReps) +
        logs.fold<int>(0, (sum, l) => sum + l.reps);
    final avgVl = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (sum, s) => sum + s.velocityLoss) /
              sessions.length;

    return SafeArea(
      bottom: false,
      child: PageWidth(
        maxWidth: 1040,
        child: RefreshIndicator(
          color: AppColors.green,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(sessionsProvider);
            ref.invalidate(setLogsProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 118),
            children: [
              PageHeader(
                title: context.t('historyTitle'),
                subtitle: context.isZh
                    ? '每一组的速度、幅度与损失都留在这里'
                    : 'Every set, velocity and loss, archived',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: context.t('vbtSessions'),
                        value: '${sessions.length}',
                        unit: context.t('sets'),
                        icon: Icons.speed_rounded,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                        label: context.t('totalReps'),
                        value: '$totalReps',
                        unit: context.t('repsShort'),
                        icon: Icons.repeat_rounded,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                        label: context.t('avgVl'),
                        value: sessions.isEmpty
                            ? '—'
                            : avgVl.toStringAsFixed(1),
                        unit: '%',
                        icon: Icons.trending_down_rounded,
                        color: avgVl >= 20 ? AppColors.orange : AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.strokeSoft),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          label: context.t('vbtSessions'),
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                      ),
                      Expanded(
                        child: _SegmentButton(
                          label: context.t('volumeSets'),
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_tab == 0)
                _buildSessions(context, sessionsAsync, sessions)
              else
                _buildLogs(context, logsAsync, logs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessions(
    BuildContext context,
    AsyncValue<List<SessionSummary>> async,
    List<SessionSummary> sessions,
  ) {
    if (async.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SurfaceCard(
          padding: EdgeInsets.zero,
          child: EmptyState(
            icon: Icons.show_chart_rounded,
            title: context.t('historyEmpty'),
            body: context.t('historyEmptyBody'),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final session in sessions)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _SessionCard(
              session: session,
              onTap: () =>
                  pushAppPage<void>(context, ReportPage(sessionId: session.id)),
              onDelete: () => _deleteSession(context, session),
            ),
          ),
      ],
    );
  }

  Widget _buildLogs(
    BuildContext context,
    AsyncValue<List<SetLog>> async,
    List<SetLog> logs,
  ) {
    if (async.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SurfaceCard(
          padding: EdgeInsets.zero,
          child: EmptyState(
            icon: Icons.edit_note_rounded,
            title: context.t('historyEmpty'),
            body: context.isZh ? '固定器械与孤立动作会以重量 × 次数 × RPE 的形式记录在这里。' : 'Machine and isolation work is logged here as weight × reps × RPE.',
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final log in logs)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _LogCard(log: log, onDelete: () => _deleteLog(context, log)),
          ),
      ],
    );
  }

  Future<void> _deleteSession(
    BuildContext context,
    SessionSummary session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('deleteSession')),
        content: Text(context.t('deleteSessionBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t('commonCancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.t('commonDelete'),
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(workoutRepositoryProvider).deleteSession(session.id);
      ref.invalidate(sessionsProvider);
      if (context.mounted) {
        showAppSnack(context, context.t('commonDelete'));
      }
    }
  }

  Future<void> _deleteLog(BuildContext context, SetLog log) async {
    await ref.read(workoutRepositoryProvider).deleteSetLog(log.id);
    ref.invalidate(setLogsProvider);
    if (context.mounted) {
      showAppSnack(context, context.t('commonDelete'));
    }
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
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
        duration: const Duration(milliseconds: 180),
        height: 38,
        decoration: BoxDecoration(
          color: selected ? AppColors.green.withValues(alpha: 0.13) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.green.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.green : AppColors.dim,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 11, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.strokeSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: numericStyle(size: 20, color: color),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(fontSize: 7.5, color: AppColors.dim),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: AppColors.dim),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  final SessionSummary session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (session.tier) {
      1 => AppColors.green,
      2 => AppColors.blue,
      _ => AppColors.orange,
    };
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TierBadge(tierValue: session.tier, compact: true),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${formatDateShort(session.startedAt, zh: context.isZh)} ${formatTime(session.startedAt)}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.dim,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MiniMetric(
                      value: '${session.totalReps}',
                      label: context.t('repsShort'),
                    ),
                    const SizedBox(width: 9),
                    _MiniMetric(
                      value: formatVelocity(session.bestMeanVelocity),
                      label: 'm/s',
                    ),
                    const SizedBox(width: 9),
                    _MiniMetric(
                      value: session.velocityLoss.toStringAsFixed(1),
                      label: 'VL%',
                      color: session.velocityLoss >= 20
                          ? AppColors.orange
                          : AppColors.muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: AppColors.dim,
            ),
            color: AppColors.surfaceHigh,
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  context.t('commonDelete'),
                  style: const TextStyle(fontSize: 13, color: AppColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.value,
    required this.label,
    this.color = AppColors.muted,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 7.5, color: AppColors.dim),
        ),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log, required this.onDelete});

  final SetLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 18,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDateShort(log.performedAt, zh: context.isZh)} ${formatTime(log.performedAt)}'
                  '  ·  ${log.weightKg > 0 ? '${formatNumber(log.weightKg)} kg' : context.t('bodyweight')} × ${log.reps}'
                  '${log.rpe > 0 ? '  ·  RPE ${log.rpe.toStringAsFixed(1)}' : ''}',
                  style: const TextStyle(fontSize: 9.5, color: AppColors.dim),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: AppColors.dim,
            ),
            color: AppColors.surfaceHigh,
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  context.t('commonDelete'),
                  style: const TextStyle(fontSize: 13, color: AppColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
