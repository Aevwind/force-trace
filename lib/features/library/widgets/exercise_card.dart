import 'package:flutter/material.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models/models.dart';

class ExerciseListCard extends StatelessWidget {
  const ExerciseListCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final color = switch (exercise.tier) {
      ExerciseTier.vbt => AppColors.green,
      ExerciseTier.pose => AppColors.blue,
      ExerciseTier.volume => AppColors.orange,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.strokeSoft),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: color.withValues(alpha: 0.22)),
                ),
                child: Icon(
                  switch (exercise.target) {
                    'quadriceps' ||
                    'quads' ||
                    'glutes' ||
                    'hamstrings' => Icons.directions_run_rounded,
                    'pectorals' ||
                    'chest' ||
                    'triceps' => Icons.fitness_center_rounded,
                    'lats' ||
                    'upper back' ||
                    'traps' => Icons.sports_gymnastics_rounded,
                    'abs' || 'waist' => Icons.self_improvement_rounded,
                    _ => Icons.accessibility_new_rounded,
                  },
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.displayName(locale),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TierBadge(
                          tierValue: exercise.tier.value,
                          compact: true,
                        ),
                      ],
                    ),
                    if (locale == 'zh' && exercise.localName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        exercise.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.dim,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      '${localizedMuscle(exercise.target, locale)} · ${localizedEquipment(exercise.equipment, locale)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.dim,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
