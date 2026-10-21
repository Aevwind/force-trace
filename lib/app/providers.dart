import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/db/seed_service.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/settings/settings.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});

final settingsProvider = ChangeNotifierProvider<SettingsController>((ref) {
  throw UnimplementedError('settingsProvider must be overridden in main()');
});

final seedServiceProvider = Provider<SeedService>((ref) {
  return SeedService(ref.watch(databaseProvider));
});

final bootstrapProvider = FutureProvider<SeedReport>((ref) {
  return ref.watch(seedServiceProvider).ensureSeeded();
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(databaseProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(ref.watch(databaseProvider));
});

final catalogProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).loadAll();
});

final exerciseDetailProvider = FutureProvider.family<ExerciseDetail?, String>((
  ref,
  id,
) {
  return ref.watch(exerciseRepositoryProvider).detail(id);
});

final sessionsProvider = StreamProvider<List<SessionSummary>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchSessions();
});

final setLogsProvider = StreamProvider<List<SetLog>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchSetLogs();
});

final sessionCountProvider = StreamProvider<int>((ref) {
  return ref.watch(workoutRepositoryProvider).watchSessionCount();
});

final sessionDetailProvider = FutureProvider.family<SessionDetail?, int>((
  ref,
  id,
) {
  return ref.watch(workoutRepositoryProvider).sessionDetail(id);
});

final planProvider = StreamProvider.family<List<PlanItem>, String>((ref, day) {
  return ref.watch(workoutRepositoryProvider).watchPlan(day);
});

class LibraryFilter {
  const LibraryFilter({
    this.query = '',
    this.tiers = const {},
    this.equipment = '',
    this.category = '',
  });

  final String query;
  final Set<int> tiers;
  final String equipment;
  final String category;

  bool get isActive =>
      query.isNotEmpty ||
      tiers.isNotEmpty ||
      equipment.isNotEmpty ||
      category.isNotEmpty;

  LibraryFilter copyWith({
    String? query,
    Set<int>? tiers,
    String? equipment,
    String? category,
    bool clearEquipment = false,
    bool clearCategory = false,
  }) {
    return LibraryFilter(
      query: query ?? this.query,
      tiers: tiers ?? this.tiers,
      equipment: clearEquipment ? '' : (equipment ?? this.equipment),
      category: clearCategory ? '' : (category ?? this.category),
    );
  }

  bool matches(Exercise exercise) {
    if (tiers.isNotEmpty && !tiers.contains(exercise.tier.value)) return false;
    if (equipment.isNotEmpty && exercise.equipment != equipment) return false;
    if (category.isNotEmpty && exercise.category != category) return false;
    if (query.trim().isEmpty) return true;
    final needles = query.toLowerCase().split(RegExp(r'\s+'));
    return needles.every(exercise.searchText.contains);
  }
}

final libraryFilterProvider = StateProvider<LibraryFilter>(
  (ref) => const LibraryFilter(),
);

final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final catalog = ref.watch(catalogProvider);
  final filter = ref.watch(libraryFilterProvider);
  return catalog.whenData(
    (all) => all.where(filter.matches).toList(growable: false),
  );
});

final todayKeyProvider = Provider<String>((ref) => dayKeyOf(DateTime.now()));

final todayPlanProvider = StreamProvider<List<PlanItem>>((ref) {
  final day = ref.watch(todayKeyProvider);
  return ref.watch(workoutRepositoryProvider).watchPlan(day);
});
