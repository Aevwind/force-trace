import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';
import '../shell/home_shell.dart';
import '../workout/workout_actions.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(todayPlanProvider).valueOrNull ?? const <PlanItem>[];
    final sessions = ref.watch(sessionsProvider).valueOrNull ?? const [];
    final logs = ref.watch(setLogsProvider).valueOrNull ?? const [];
    final catalog =
        ref.watch(catalogProvider).valueOrNull ?? const <Exercise>[];

    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final weekSessions = sessions
        .where((s) => s.startedAt.isAfter(weekStart))
        .toList();
    final weekLogs = logs
        .where((l) => l.performedAt.isAfter(weekStart))
        .toList();
    final volume =
        weekSessions.fold<double>(
          0,
          (sum, s) => sum + s.weightKg * s.totalReps,
        ) +
        weekLogs.fold<double>(0, (sum, l) => sum + l.weightKg * l.reps);
    final avgVl = weekSessions.isEmpty
        ? 0.0
        : weekSessions.fold<double>(0, (sum, s) => sum + s.velocityLoss) /
              weekSessions.length;

    final plannedSets = plan.fold<int>(0, (sum, p) => sum + p.targetSets);
    final doneSets = plan.fold<int>(0, (sum, p) => sum + p.completedSets);
    final featured = _featured(catalog);

    return SafeArea(
      bottom: false,
      child: PageWidth(
        maxWidth: 1000,
        child: RefreshIndicator(
          color: AppColors.green,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(catalogProvider);
            ref.invalidate(sessionsProvider);
            ref.invalidate(setLogsProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 118),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    const AppLogoMark(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${context.t('appName')} ',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                'FORCETRACE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: AppColors.dim.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_greeting(context, now)} · ${_dateLabel(context, now)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    HeaderIconButton(
                      icon: Icons.search_rounded,
                      onTap: () => _showAddSheet(context, ref, catalog),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _HeroCard(
                  plannedSets: plannedSets,
                  doneSets: doneSets,
                  exerciseCount: plan.length,
                  weekSessions: weekSessions.length,
                  volume: volume,
                  avgVl: avgVl,
                  onAdd: () => _showAddSheet(context, ref, catalog),
                ),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: context.t('todayPlan'),
                  subtitle: plan.isEmpty
                      ? null
                      : context.isZh
                      ? '$doneSets / $plannedSets 组已完成'
                      : '$doneSets / $plannedSets sets complete',
                  trailing: TextButton.icon(
                    onPressed: () => _showAddSheet(context, ref, catalog),
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: Text(context.t('commonAdd')),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (plan.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: EmptyState(
                      icon: Icons.event_available_rounded,
                      title: context.t('noPlanTitle'),
                      body: context.t('noPlanBody'),
                      actionLabel: context.t('addExercises'),
                      onAction: () => _showAddSheet(context, ref, catalog),
                    ),
                  ),
                )
              else
                ...plan.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _PlanCard(
                      item: entry.value,
                      index: entry.key,
                      onStart: () => startExercise(
                        context,
                        ref,
                        _exerciseFor(catalog, entry.value),
                        targetReps: entry.value.targetReps,
                        weightKg: entry.value.weightKg,
                        planDay: ref.read(todayKeyProvider),
                        planItemId: entry.value.id,
                      ),
                      onRemove: () => ref
                          .read(workoutRepositoryProvider)
                          .removeFromPlan(
                            exerciseId: entry.value.exerciseId,
                            dayKey: ref.read(todayKeyProvider),
                          ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: context.isZh ? '快速开始' : 'Quick start',
                  subtitle: context.isZh
                      ? 'Tier 1 核心动作 · 直接进入视觉追踪'
                      : 'Tier 1 lifts · jump straight into tracking',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 154,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final exercise = featured[index];
                    return _QuickStartCard(
                      exercise: exercise,
                      onTap: () =>
                          startExercise(context, ref, exercise, targetReps: 5),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _DemoNotice(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Exercise _exerciseFor(List<Exercise> catalog, PlanItem item) {
    return catalog.firstWhere(
      (e) => e.id == item.exerciseId,
      orElse: () => Exercise(
        id: item.exerciseId,
        name: item.exerciseName,
        localName: item.localName,
        category: '',
        bodyPart: '',
        equipment: '',
        target: '',
        secondaryMuscles: const [],
        tier: item.tier,
        mediaId: '',
      ),
    );
  }

  List<Exercise> _featured(List<Exercise> catalog) {
    const preferred = [
      'barbell full squat',
      'barbell bench press',
      'barbell deadlift',
      'barbell bent over row',
      'pull-up',
      'barbell seated overhead press',
    ];
    final result = <Exercise>[];
    for (final name in preferred) {
      final match = catalog.where((e) => e.name == name).firstOrNull;
      if (match != null) result.add(match);
    }
    if (result.length < 4) {
      result.addAll(
        catalog
            .where((e) => e.tier == ExerciseTier.vbt && !result.contains(e))
            .take(6 - result.length),
      );
    }
    return result;
  }

  String _greeting(BuildContext context, DateTime now) {
    if (now.hour < 11) return context.t('greetingMorning');
    if (now.hour < 18) return context.t('greetingAfternoon');
    return context.t('greetingEvening');
  }

  String _dateLabel(BuildContext context, DateTime now) {
    const zhWeekdays = ['一', '二', '三', '四', '五', '六', '日'];
    if (context.isZh) {
      return '${now.month}月${now.day}日 周${zhWeekdays[now.weekday - 1]}';
    }
    const enWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${enWeekdays[now.weekday - 1]}, ${now.month}/${now.day}';
  }

  void _showAddSheet(
    BuildContext context,
    WidgetRef ref,
    List<Exercise> catalog,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExerciseSheet(catalog: catalog),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.plannedSets,
    required this.doneSets,
    required this.exerciseCount,
    required this.weekSessions,
    required this.volume,
    required this.avgVl,
    required this.onAdd,
  });

  final int plannedSets;
  final int doneSets;
  final int exerciseCount;
  final int weekSessions;
  final double volume;
  final double avgVl;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final progress = plannedSets == 0
        ? 0.0
        : (doneSets / plannedSets).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15251D), Color(0xFF101820)],
        ),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -40,
              child: SizedBox(
                width: 190,
                height: 190,
                child: CustomPaint(
                  painter: _RingBackdropPainter(progress: progress),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const PulseDot(size: 6),
                                const SizedBox(width: 7),
                                Text(
                                  context.t('readyTitle').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    color: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              plannedSets == 0
                                  ? context.t('noPlanTitle')
                                  : context.isZh
                                  ? '$exerciseCount 个动作 · $plannedSets 组'
                                  : '$exerciseCount exercises · $plannedSets sets',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(height: 1.15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.t('todaySubtitle'),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      _ProgressRing(progress: progress),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _MiniStat(
                        value: '$weekSessions',
                        label: context.t('weeklySessions'),
                        unit: context.t('weeklySessionsUnit'),
                      ),
                      _divider(),
                      _MiniStat(
                        value: volume >= 1000
                            ? '${(volume / 1000).toStringAsFixed(1)}t'
                            : '${volume.round()}',
                        label: context.t('weeklyVolume'),
                        unit: 'kg',
                      ),
                      _divider(),
                      _MiniStat(
                        value: avgVl.toStringAsFixed(1),
                        label: context.t('avgVl'),
                        unit: '%',
                        color: avgVl > (plannedSets == 0 ? 100 : 20)
                            ? AppColors.orange
                            : AppColors.text,
                      ),
                      const Spacer(),
                      if (plannedSets == 0)
                        IconButton(
                          onPressed: onAdd,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.green.withValues(
                              alpha: 0.14,
                            ),
                            foregroundColor: AppColors.green,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 20),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 26,
    margin: const EdgeInsets.symmetric(horizontal: 14),
    color: Colors.white.withValues(alpha: 0.07),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.unit,
    this.color = AppColors.text,
  });

  final String value;
  final String label;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: numericStyle(size: 20, color: color)),
            const SizedBox(width: 3),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.dim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(fontSize: 10.5),
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: numericStyle(size: 15, color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

class _RingBackdropPainter extends CustomPainter {
  const _RingBackdropPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      paint.color = AppColors.green.withValues(alpha: 0.07 - i * 0.012);
      canvas.drawCircle(center, 32.0 + i * 22, paint);
    }
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.green.withValues(alpha: 0.28);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 78),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingBackdropPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.item,
    required this.index,
    required this.onStart,
    required this.onRemove,
  });

  final PlanItem item;
  final int index;
  final VoidCallback onStart;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.tier) {
      ExerciseTier.vbt => AppColors.green,
      ExerciseTier.pose => AppColors.blue,
      ExerciseTier.volume => AppColors.orange,
    };
    final progress = item.targetSets == 0
        ? 0.0
        : (item.completedSets / item.targetSets).clamp(0.0, 1.0);
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      onTap: onStart,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: numericStyle(size: 16, color: color),
                ),
                const SizedBox(height: 3),
                Text(
                  'SET',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.displayName(
                          Localizations.localeOf(context).languageCode,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TierBadge(tierValue: item.tier.value, compact: true),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.dim,
                      ),
                      color: AppColors.surfaceHigh,
                      onSelected: (value) {
                        if (value == 'remove') onRemove();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'remove',
                          child: Text(
                            context.isZh ? '从今日计划移除' : 'Remove from today',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.targetSets} ${context.t('sets')} × ${item.targetReps} ${context.t('reps')}'
                  '${item.weightKg > 0 ? ' · ${item.weightKg.toStringAsFixed(item.weightKg % 1 == 0 ? 0 : 1)} kg' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    for (var i = 0; i < item.targetSets; i++) ...[
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: i < item.completedSets
                                ? color
                                : Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      if (i != item.targetSets - 1) const SizedBox(width: 4),
                    ],
                    const SizedBox(width: 10),
                    Text(
                      '${(progress * 100).round()}%',
                      style: numericStyle(
                        size: 11,
                        color: progress >= 1 ? AppColors.green : AppColors.dim,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.tier == ExerciseTier.volume
                  ? Icons.add_rounded
                  : Icons.play_arrow_rounded,
              color: color,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (exercise.tier) {
      ExerciseTier.vbt => AppColors.green,
      ExerciseTier.pose => AppColors.blue,
      ExerciseTier.volume => AppColors.orange,
    };
    return SizedBox(
      width: 208,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.14), AppColors.surface],
              ),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TierBadge(tierValue: exercise.tier.value, compact: true),
                    const Spacer(),
                    Icon(Icons.north_east_rounded, size: 16, color: color),
                  ],
                ),
                const Spacer(),
                Text(
                  exercise.displayName(
                    Localizations.localeOf(context).languageCode,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${localizedMuscle(exercise.target, Localizations.localeOf(context).languageCode)} · ${localizedEquipment(exercise.equipment, Localizations.localeOf(context).languageCode)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.dim),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, size: 17, color: AppColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t('demoNoticeBody'),
              style: const TextStyle(
                fontSize: 11,
                height: 1.55,
                color: AppColors.dim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddExerciseSheet extends ConsumerStatefulWidget {
  const _AddExerciseSheet({required this.catalog});

  final List<Exercise> catalog;

  @override
  ConsumerState<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends ConsumerState<_AddExerciseSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  int? _tier;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(todayPlanProvider).valueOrNull ?? const <PlanItem>[];
    final plannedIds = plan.map((p) => p.exerciseId).toSet();
    var items =
        widget.catalog.where((e) {
          if (_tier != null && e.tier.value != _tier) return false;
          if (_query.trim().isEmpty) return true;
          return e.searchText.contains(_query.toLowerCase());
        }).toList()..sort((a, b) {
          final tierCompare = a.tier.value.compareTo(b.tier.value);
          return tierCompare != 0 ? tierCompare : a.name.compareTo(b.name);
        });
    items = items.take(_query.isEmpty ? 70 : 120).toList();

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.86,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.stroke,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.t('addExercises'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.t('commonDone')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: TextField(
              controller: _search,
              autofocus: false,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: context.t('searchHint'),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.dim,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _tierChip(null, context.t('commonAll')),
                _tierChip(1, context.t('tier1Short')),
                _tierChip(2, context.t('tier2Short')),
                _tierChip(3, context.t('tier3Short')),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final exercise = items[index];
                final added = plannedIds.contains(exercise.id);
                return ListTile(
                  onTap: added
                      ? null
                      : () async {
                          await addExerciseToToday(
                            context,
                            ref,
                            exercise,
                            targetSets: exercise.tier == ExerciseTier.vbt
                                ? 4
                                : 3,
                            targetReps: exercise.tier == ExerciseTier.vbt
                                ? 5
                                : 8,
                          );
                        },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      switch (exercise.tier) {
                        ExerciseTier.vbt => Icons.speed_rounded,
                        ExerciseTier.pose => Icons.accessibility_new_rounded,
                        ExerciseTier.volume => Icons.fitness_center_rounded,
                      },
                      size: 18,
                      color: added ? AppColors.green : AppColors.muted,
                    ),
                  ),
                  title: Text(
                    exercise.displayName(
                      Localizations.localeOf(context).languageCode,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${localizedMuscle(exercise.target, Localizations.localeOf(context).languageCode)} · ${localizedEquipment(exercise.equipment, Localizations.localeOf(context).languageCode)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.dim),
                  ),
                  trailing: added
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green,
                          size: 20,
                        )
                      : const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.dim,
                          size: 20,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierChip(int? tier, String label) {
    final selected = _tier == tier;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _tier = tier),
      ),
    );
  }
}
