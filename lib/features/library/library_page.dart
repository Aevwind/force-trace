import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/models.dart';
import '../shell/home_shell.dart';
import 'exercise_detail_page.dart';
import 'widgets/exercise_card.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(libraryFilterProvider);
    final async = ref.watch(filteredExercisesProvider);
    final all = ref.watch(catalogProvider).valueOrNull ?? const <Exercise>[];
    final count = async.valueOrNull?.length ?? 0;

    return SafeArea(
      bottom: false,
      child: PageWidth(
        maxWidth: 1180,
        child: Column(
          children: [
            PageHeader(
              title: context.t('libraryTitle'),
              subtitle: context.t('librarySubtitle'),
              actions: [
                HeaderIconButton(
                  icon: Icons.tune_rounded,
                  onTap: () => _showFilters(context, all),
                  badge:
                      filter.equipment.isNotEmpty || filter.category.isNotEmpty
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                onChanged: (value) =>
                    ref.read(libraryFilterProvider.notifier).state = filter
                        .copyWith(query: value),
                decoration: InputDecoration(
                  hintText: context.t('searchHint'),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.dim,
                  ),
                  suffixIcon: filter.query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _search.clear();
                            ref.read(libraryFilterProvider.notifier).state =
                                filter.copyWith(query: '');
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _TierChip(
                    label: context.t('commonAll'),
                    selected: filter.tiers.isEmpty,
                    onTap: () =>
                        ref.read(libraryFilterProvider.notifier).state = filter
                            .copyWith(tiers: {}),
                  ),
                  const SizedBox(width: 8),
                  for (final tier in [1, 2, 3])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _TierChip(
                        label: context.t('tier${tier}Short'),
                        color: switch (tier) {
                          1 => AppColors.green,
                          2 => AppColors.blue,
                          _ => AppColors.orange,
                        },
                        selected: filter.tiers.contains(tier),
                        onTap: () {
                          final next = Set<int>.from(filter.tiers);
                          if (!next.remove(tier)) next.add(tier);
                          ref.read(libraryFilterProvider.notifier).state =
                              filter.copyWith(tiers: next);
                        },
                      ),
                    ),
                  if (filter.equipment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ActiveChip(
                        label: localizedEquipment(
                          filter.equipment,
                          Localizations.localeOf(context).languageCode,
                        ),
                        onClear: () =>
                            ref.read(libraryFilterProvider.notifier).state =
                                filter.copyWith(clearEquipment: true),
                      ),
                    ),
                  if (filter.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ActiveChip(
                        label: localizedCategory(
                          filter.category,
                          Localizations.localeOf(context).languageCode,
                        ),
                        onClear: () =>
                            ref.read(libraryFilterProvider.notifier).state =
                                filter.copyWith(clearCategory: true),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(
                children: [
                  Text(
                    '${NumberFormat.decimalPattern().format(count)} ${context.t('results')}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dim,
                    ),
                  ),
                  const Spacer(),
                  if (filter.isActive)
                    GestureDetector(
                      onTap: () {
                        _search.clear();
                        ref.read(libraryFilterProvider.notifier).state =
                            const LibraryFilter();
                      },
                      child: Text(
                        context.isZh ? '清除筛选' : 'Clear filters',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
                error: (error, stack) => EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: context.t('errorGeneric'),
                  body: '$error',
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: context.t('noResults'),
                      body: context.t('noResultsBody'),
                      actionLabel: filter.isActive
                          ? context.t('commonAll')
                          : null,
                      onAction: filter.isActive
                          ? () {
                              _search.clear();
                              ref.read(libraryFilterProvider.notifier).state =
                                  const LibraryFilter();
                            }
                          : null,
                    );
                  }
                  final sorted = [...items]
                    ..sort((a, b) {
                      final tier = a.tier.value.compareTo(b.tier.value);
                      return tier != 0 ? tier : a.name.compareTo(b.name);
                    });
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 760;
                      final columns = constraints.maxWidth >= 1180 ? 3 : 2;
                      if (!wide) {
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
                          itemCount: sorted.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => ExerciseListCard(
                            exercise: sorted[index],
                            onTap: () => _open(context, sorted[index]),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 96,
                        ),
                        itemCount: sorted.length,
                        itemBuilder: (context, index) => ExerciseListCard(
                          exercise: sorted[index],
                          onTap: () => _open(context, sorted[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Exercise exercise) {
    pushAppPage<void>(context, ExerciseDetailPage(exerciseId: exercise.id));
  }

  void _showFilters(BuildContext context, List<Exercise> catalog) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(catalog: catalog),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.green,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.13) : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.45)
                : AppColors.strokeSoft,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected ? color : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.strokeSoft),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          IconButton(
            onPressed: onClear,
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, color: AppColors.dim),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet({required this.catalog});

  final List<Exercise> catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(libraryFilterProvider);
    final categories =
        catalog
            .map((e) => e.category)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final equipment =
        catalog
            .map((e) => e.equipment)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                context.t('filters'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(libraryFilterProvider.notifier).state =
                      const LibraryFilter();
                },
                child: Text(context.isZh ? '重置' : 'Reset'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('category'),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((raw) {
                      final selected = filter.category == raw;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(localizedCategory(raw, locale)),
                        onSelected: (_) {
                          ref
                              .read(libraryFilterProvider.notifier)
                              .state = selected
                              ? filter.copyWith(clearCategory: true)
                              : filter.copyWith(category: raw);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    context.t('equipment'),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: equipment.map((raw) {
                      final selected = filter.equipment == raw;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(localizedEquipment(raw, locale)),
                        onSelected: (_) {
                          ref
                              .read(libraryFilterProvider.notifier)
                              .state = selected
                              ? filter.copyWith(clearEquipment: true)
                              : filter.copyWith(equipment: raw);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.t('commonDone')),
            ),
          ),
        ],
      ),
    );
  }
}
