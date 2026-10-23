import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import 'muscle_map.dart';

/// Translate the atlas's anatomical groups into the catalog's body categories.
/// Keep left/right sides and front/back views on the same category selection.
String categoryForAtlasMuscle(MuscleInfo muscle) {
  final id = muscle.id;
  if (id.startsWith('trapezius')) return 'back';
  return switch (muscle.group) {
    MuscleGroup.chest => 'chest',
    MuscleGroup.shoulders => 'shoulders',
    MuscleGroup.back => 'back',
    MuscleGroup.core => 'waist',
    MuscleGroup.neck => 'neck',
    MuscleGroup.glutes ||
    MuscleGroup.hamstrings ||
    MuscleGroup.adductors => 'upper legs',
    MuscleGroup.arms =>
      id.startsWith('biceps_brachii') ||
              id.startsWith('triceps_brachii') ||
              id.startsWith('anconeus')
          ? 'upper arms'
          : 'lower arms',
    MuscleGroup.legs =>
      const [
            'gastrocnemius',
            'soleus',
            'tibialis',
            'fibularis',
            'extensor_hallucis_longus',
            'extensor_digitorum_longus',
          ].any(id.startsWith)
          ? 'lower legs'
          : 'upper legs',
  };
}

class BodyCategoryFilter extends StatefulWidget {
  const BodyCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.availableCategories,
    required this.onChanged,
  });

  final String selectedCategory;
  final Set<String> availableCategories;
  final ValueChanged<String> onChanged;

  @override
  State<BodyCategoryFilter> createState() => _BodyCategoryFilterState();
}

class _BodyCategoryFilterState extends State<BodyCategoryFilter> {
  MuscleInfo? _hovered;

  void _select(MuscleInfo muscle) {
    final category = categoryForAtlasMuscle(muscle);
    if (!widget.availableCategories.contains(category)) return;
    widget.onChanged(category == widget.selectedCategory ? '' : category);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final selected = widget.selectedCategory;
    final colors = <MuscleInfo, Color?>{
      for (final muscle in MuscleCatalog.all)
        if (selected.isNotEmpty && categoryForAtlasMuscle(muscle) == selected)
          muscle: AppColors.green,
    };

    Widget pane(AtlasAsset view, String label) => Expanded(
      child: Column(
        children: [
          Expanded(
            child: BodyAtlasView<MuscleInfo>(
              view: view,
              resolver: const MuscleResolver(),
              colorMapping: colors,
              hoveredOver: _hovered,
              hoverColor: (color) => Color.lerp(color, AppColors.green, 0.65),
              onTapElement: _select,
              onHoverOverElement: (muscle) {
                final next =
                    muscle != null &&
                        widget.availableCategories.contains(
                          categoryForAtlasMuscle(muscle),
                        )
                    ? muscle
                    : null;
                if (_hovered != next) setState(() => _hovered = next);
              },
              semanticLabel: '${context.t('bodyFilter')}, $label',
              elementSemanticLabel: (muscle) =>
                  '${atlasMuscleLabel(muscle, locale)}, '
                  '${localizedCategory(categoryForAtlasMuscle(muscle), locale)}',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.dim),
          ),
        ],
      ),
    );

    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected.isEmpty
                        ? context.t('bodyFilter')
                        : '${context.t('bodyFilter')} · ${localizedCategory(selected, locale)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selected.isNotEmpty)
                  IconButton(
                    tooltip: context.t('clearBodyFilter'),
                    onPressed: () => widget.onChanged(''),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final height = (constraints.maxWidth * 0.95).clamp(220.0, 310.0);
              return Center(
                child: SizedBox(
                  width: 360,
                  height: height,
                  child: Row(
                    children: [
                      pane(AtlasAsset.musclesFront, context.t('bodyFront')),
                      const SizedBox(width: 12),
                      pane(AtlasAsset.musclesBack, context.t('bodyBack')),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            context.t('bodyFilterHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('bodyAtlasAttribution'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8.5, color: AppColors.dim),
          ),
        ],
      ),
    );
  }
}
