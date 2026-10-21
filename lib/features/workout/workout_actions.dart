import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';
import '../live/live_hud_page.dart';
import 'log_set_sheet.dart';

/// Primary CTA for an exercise: VBT/pose tracking for Tier 1–2, a classic set
/// logger for Tier 3.
Future<void> startExercise(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise, {
  int? targetReps,
  double weightKg = 0,
  String? planDay,
  int? planItemId,
}) async {
  if (exercise.tier.supportsPose) {
    await pushAppPage<void>(
      context,
      LiveHudPage(
        exercise: exercise,
        targetReps: targetReps ?? 5,
        initialWeightKg: weightKg,
        planDay: planDay,
        planItemId: planItemId,
      ),
    );
    return;
  }
  await logVolumeSet(
    context,
    ref,
    exercise,
    initialWeight: weightKg,
    planDay: planDay,
    planItemId: planItemId,
  );
}

Future<void> logVolumeSet(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise, {
  double initialWeight = 0,
  String? planDay,
  int? planItemId,
  int currentSet = 1,
}) async {
  final draft = await showLogSetSheet(
    context,
    exercise: exercise,
    initialWeight: initialWeight,
  );
  if (draft == null || !context.mounted) return;

  try {
    await ref
        .read(workoutRepositoryProvider)
        .logSet(
          exercise: exercise,
          weightKg: draft.weightKg,
          reps: draft.reps,
          rpe: draft.rpe,
          restSeconds: draft.restSeconds,
          notes: draft.notes,
        );
    if (planDay != null && planItemId != null) {
      final plan = await ref.read(planProvider(planDay).future);
      final item = plan.where((p) => p.id == planItemId).firstOrNull;
      if (item != null) {
        await ref
            .read(workoutRepositoryProvider)
            .completePlanSet(
              exerciseId: exercise.id,
              dayKey: planDay,
              targetSets: item.targetSets,
            );
      }
    }
  } catch (error) {
    if (context.mounted) {
      showAppSnack(context, '$error', error: true);
    }
    return;
  }
  if (!context.mounted) return;
  showAppSnack(context, context.t('logSetSaved'));
  final language = Localizations.localeOf(context).languageCode;
  await showRestTimer(
    context,
    seconds: draft.restSeconds,
    exerciseName: exercise.displayName(language),
    nextSet: currentSet + 1,
  );
}

Future<void> addExerciseToToday(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise, {
  int targetSets = 3,
  int targetReps = 8,
}) async {
  final day = ref.read(todayKeyProvider);
  await ref
      .read(workoutRepositoryProvider)
      .addToPlan(
        exercise: exercise,
        dayKey: day,
        targetSets: targetSets,
        targetReps: targetReps,
      );
  if (context.mounted) {
    showAppSnack(context, context.t('addedToPlan'));
  }
}
