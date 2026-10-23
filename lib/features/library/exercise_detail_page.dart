import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';
import '../workout/workout_actions.dart';
import 'widgets/exercise_preview.dart';
import 'widgets/muscle_map.dart';

class ExerciseDetailPage extends ConsumerStatefulWidget {
  const ExerciseDetailPage({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends ConsumerState<ExerciseDetailPage> {
  String? _instructionLanguage;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(exerciseDetailProvider(widget.exerciseId));
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: async.when(
            loading: () => const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
            error: (error, stack) => Center(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: context.t('errorGeneric'),
                body: '$error',
                actionLabel: context.t('commonBack'),
                onAction: () => Navigator.of(context).pop(),
              ),
            ),
            data: (detail) {
              if (detail == null) {
                return Center(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: context.t('noResults'),
                    body: '',
                    actionLabel: context.t('commonBack'),
                    onAction: () => Navigator.of(context).pop(),
                  ),
                );
              }
              return _DetailContent(
                detail: detail,
                locale: locale,
                instructionLanguage:
                    _instructionLanguage ??
                    (detail.steps.containsKey('zh') ? 'zh' : 'en'),
                onLanguageChanged: (value) =>
                    setState(() => _instructionLanguage = value),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: async.valueOrNull == null
          ? null
          : _DetailActions(exercise: async.valueOrNull!.exercise),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({
    required this.detail,
    required this.locale,
    required this.instructionLanguage,
    required this.onLanguageChanged,
  });

  final ExerciseDetail detail;
  final String locale;
  final String instructionLanguage;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = detail.exercise;
    final tierColor = switch (exercise.tier) {
      ExerciseTier.vbt => AppColors.green,
      ExerciseTier.pose => AppColors.blue,
      ExerciseTier.volume => AppColors.orange,
    };
    final steps = detail.stepsFor(instructionLanguage);
    final hasExactLanguage = detail.steps.containsKey(instructionLanguage);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 21),
              ),
              Expanded(
                child: Text(
                  context.t('overview'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: context.t('addToPlan'),
                onPressed: () => addExerciseToToday(context, ref, exercise),
                icon: const Icon(Icons.playlist_add_rounded, size: 22),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ExercisePreview(exercise: exercise),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 218,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tierColor.withValues(alpha: 0.18), AppColors.surface],
              ),
              border: Border.all(color: tierColor.withValues(alpha: 0.22)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    bottom: -38,
                    child: Transform.rotate(
                      angle: -0.35,
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 210,
                        color: Colors.white.withValues(alpha: 0.035),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TierBadge(tierValue: exercise.tier.value),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  localizedEquipment(
                                    exercise.equipment,
                                    locale,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          exercise.displayName(locale),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.1,
                            color: AppColors.text,
                          ),
                        ),
                        if (locale == 'zh') ...[
                          const SizedBox(height: 5),
                          Text(
                            exercise.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.dim,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Pill(
                              icon: Icons.my_location_rounded,
                              label: localizedMuscle(exercise.target, locale),
                              color: tierColor,
                            ),
                            const SizedBox(width: 8),
                            _Pill(
                              icon: Icons.grid_view_rounded,
                              label: localizedCategory(
                                exercise.category,
                                locale,
                              ),
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.t('muscles'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      'flutter_body_atlas',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.dim,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MuscleMap(
                  target: exercise.target,
                  secondary: exercise.secondaryMuscles,
                  locale: locale,
                  height: 320,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.fitness_center_rounded,
                  label: context.t('equipment'),
                  value: localizedEquipment(exercise.equipment, locale),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.category_rounded,
                  label: context.t('category'),
                  value: localizedCategory(exercise.category, locale),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.bolt_rounded,
                  label: context.t('tier'),
                  value: context.t('tier${exercise.tier.value}Short'),
                  color: tierColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.layers_rounded,
                  label: context.t('secondary'),
                  value: exercise.secondaryMuscles.isEmpty
                      ? '—'
                      : exercise.secondaryMuscles
                            .take(2)
                            .map((m) => localizedMuscle(m, locale))
                            .join(' / '),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.t('instructions'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    _LanguagePicker(
                      value: instructionLanguage,
                      onChanged: onLanguageChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('steps'),
                  style: const TextStyle(fontSize: 10.5, color: AppColors.dim),
                ),
                const SizedBox(height: 14),
                if (steps.isEmpty)
                  Text(
                    context.t('noInstructions'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...steps.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: tierColor.withValues(alpha: 0.25),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: tierColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.65,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!hasExactLanguage && steps.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      context.isZh
                          ? '该语言暂无教程，已显示英文。'
                          : 'Showing English fallback for this language.',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.dim,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.strokeSoft),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: AppColors.dim,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('settingsDataset'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          height: 1.5,
                          color: AppColors.dim,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.t('settingsAttribution'),
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: AppColors.dim,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.t('bodyAtlasAttribution'),
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: AppColors.dim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _DetailActions extends ConsumerWidget {
  const _DetailActions({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: AppColors.strokeSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => addExerciseToToday(context, ref, exercise),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        context.t('addToPlan'),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => startExercise(
                  context,
                  ref,
                  exercise,
                  targetReps: exercise.tier == ExerciseTier.vbt ? 5 : 8,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exercise.tier == ExerciseTier.volume
                            ? Icons.edit_note_rounded
                            : Icons.center_focus_strong_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        exercise.tier == ExerciseTier.volume
                            ? context.t('quickLog')
                            : context.t('startVbt'),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.text,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.strokeSoft),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.dim),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: AppColors.dim),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.strokeSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          dropdownColor: AppColors.surfaceHigh,
          icon: const Icon(Icons.expand_more_rounded, size: 16),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
          items: [
            for (final lang in kInstructionLanguages)
              DropdownMenuItem(
                value: lang.$1,
                child: Text(lang.$2, style: const TextStyle(fontSize: 11)),
              ),
          ],
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ),
    );
  }
}
