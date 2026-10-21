import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

/// Interactive anatomical muscle atlas backed by `flutter_body_atlas`.
///
/// The package exposes a high-fidelity SVG front/back view with stable muscle
/// IDs; exercise targets from the dataset are translated into atlas muscles and
/// highlighted green (primary) / orange (secondary).
class MuscleMap extends StatefulWidget {
  const MuscleMap({
    super.key,
    required this.target,
    required this.secondary,
    required this.locale,
    this.height = 300,
    this.showLegend = true,
  });

  final String target;
  final List<String> secondary;
  final String locale;
  final double height;
  final bool showLegend;

  @override
  State<MuscleMap> createState() => _MuscleMapState();
}

class _MuscleMapState extends State<MuscleMap> {
  MuscleInfo? _selected;
  MuscleInfo? _hovered;

  @override
  Widget build(BuildContext context) {
    final primary = muscleInfosForTarget(widget.target);
    final secondary = <MuscleInfo>{
      for (final raw in widget.secondary) ...muscleInfosForTarget(raw),
    }..removeAll(primary);

    // Insert secondary first, primary last: the package paints entries in map
    // iteration order, so a primary muscle always wins a shared SVG path.
    final colorMapping = <MuscleInfo, Color?>{};
    for (final muscle in secondary) {
      colorMapping[muscle] = AppColors.orange;
    }
    for (final muscle in primary) {
      colorMapping[muscle] = AppColors.green;
    }

    final selected = _selected;
    final noLayer = primary.isEmpty && secondary.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.height * 0.516 * 2 + 18,
            ),
            child: SizedBox(
              height: widget.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _AtlasPane(
                      view: AtlasAsset.musclesFront,
                      label: widget.locale == 'zh' ? '正面' : 'FRONT',
                      colorMapping: colorMapping,
                      hovered: _hovered,
                      primary: primary,
                      secondary: secondary,
                      locale: widget.locale,
                      onTap: (muscle) => setState(() => _selected = muscle),
                      onHover: (muscle) => setState(() => _hovered = muscle),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AtlasPane(
                      view: AtlasAsset.musclesBack,
                      label: widget.locale == 'zh' ? '背面' : 'BACK',
                      colorMapping: colorMapping,
                      hovered: _hovered,
                      primary: primary,
                      secondary: secondary,
                      locale: widget.locale,
                      onTap: (muscle) => setState(() => _selected = muscle),
                      onHover: (muscle) => setState(() => _hovered = muscle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected == null
                      ? _AtlasHint(
                          key: const ValueKey('hint'),
                          locale: widget.locale,
                        )
                      : _SelectedMuscle(
                          key: ValueKey(selected.id),
                          muscle: selected,
                          primary: primary.contains(selected),
                          secondary: secondary.contains(selected),
                          locale: widget.locale,
                          onClear: () => setState(() => _selected = null),
                        ),
                ),
                if (widget.showLegend) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      _LegendDot(
                        color: AppColors.green,
                        label:
                            '${widget.locale == 'zh' ? '主肌群' : 'Primary'} · ${localizedMuscle(widget.target, widget.locale)}',
                        bold: true,
                      ),
                      for (final muscle in widget.secondary.take(3))
                        _LegendDot(
                          color: AppColors.orange,
                          label: localizedMuscle(muscle, widget.locale),
                        ),
                    ],
                  ),
                ],
                if (noLayer) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.locale == 'zh' ? '该目标肌群暂不在图谱图层中，已保留动作信息。' : 'This target is not drawn on the current atlas layer.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9.5, color: AppColors.dim),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.accessibility_new_rounded,
                      size: 12,
                      color: AppColors.dim,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        context.t('bodyAtlasAttribution'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: AppColors.dim,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AtlasPane extends StatelessWidget {
  const _AtlasPane({
    required this.view,
    required this.label,
    required this.colorMapping,
    required this.hovered,
    required this.primary,
    required this.secondary,
    required this.locale,
    required this.onTap,
    required this.onHover,
  });

  final AtlasAsset view;
  final String label;
  final Map<MuscleInfo, Color?> colorMapping;
  final MuscleInfo? hovered;
  final Set<MuscleInfo> primary;
  final Set<MuscleInfo> secondary;
  final String locale;
  final ValueChanged<MuscleInfo> onTap;
  final ValueChanged<MuscleInfo?> onHover;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BodyAtlasView<MuscleInfo>(
            view: view,
            resolver: const MuscleResolver(),
            colorMapping: colorMapping,
            hoveredOver: hovered,
            hoverColor: (color) => Color.lerp(color, Colors.white, 0.2),
            onTapElement: onTap,
            onHoverOverElement: onHover,
            semanticLabel: locale == 'zh'
                ? '人体肌群图谱，$label'
                : 'Muscle atlas, $label',
            elementSemanticLabel: (muscle) {
              final name = atlasMuscleLabel(muscle, locale);
              if (primary.contains(muscle)) {
                return locale == 'zh' ? '$name，主肌群' : '$name, primary';
              }
              if (secondary.contains(muscle)) {
                return locale == 'zh' ? '$name，协同肌群' : '$name, secondary';
              }
              return name;
            },
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.dim,
          ),
        ),
      ],
    );
  }
}

class _AtlasHint extends StatelessWidget {
  const _AtlasHint({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.touch_app_rounded, size: 13, color: AppColors.dim),
        const SizedBox(width: 6),
        Text(
          locale == 'zh' ? '点击肌肉查看名称与颜色含义' : 'Tap a muscle to inspect it',
          style: const TextStyle(fontSize: 10, color: AppColors.dim),
        ),
      ],
    );
  }
}

class _SelectedMuscle extends StatelessWidget {
  const _SelectedMuscle({
    super.key,
    required this.muscle,
    required this.primary,
    required this.secondary,
    required this.locale,
    required this.onClear,
  });

  final MuscleInfo muscle;
  final bool primary;
  final bool secondary;
  final String locale;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final color = primary
        ? AppColors.green
        : secondary
        ? AppColors.orange
        : AppColors.muted;
    final role = primary
        ? (locale == 'zh' ? '主肌群' : 'primary')
        : secondary
        ? (locale == 'zh' ? '协同肌群' : 'secondary')
        : (locale == 'zh' ? '未激活' : 'inactive');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${atlasMuscleLabel(muscle, locale)} · ${_cleanDisplayName(muscle)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            role,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: AppColors.dim,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.bold = false,
  });

  final Color color;
  final String label;
  final bool bold;

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
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? AppColors.text : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

/// Maps a dataset target/muscle string to atlas `MuscleInfo` records.
///
/// Dataset labels use broad groups ("quads", "delts", "upper back"), while the
/// atlas exposes individual heads and left/right paths. This mapping is the
/// single translation layer between them.
Set<MuscleInfo> muscleInfosForTarget(String raw) {
  final value = raw.toLowerCase().trim();
  if (value.isEmpty) return const {};

  Set<MuscleInfo> fromGroup(MuscleGroup group) => {
    for (final muscle in MuscleCatalog.all)
      if (muscle.group == group) muscle,
  };
  Set<MuscleInfo> byPrefixes(List<String> prefixes) => {
    for (final muscle in MuscleCatalog.all)
      if (prefixes.any(muscle.id.startsWith)) muscle,
  };

  if (value.contains('chest') || value.contains('pectoral')) {
    return fromGroup(MuscleGroup.chest);
  }
  if (value.contains('abs') || value.contains('rectus abdominis')) {
    return byPrefixes(const ['rectus_abdominis']);
  }
  if (value.contains('oblique')) {
    return byPrefixes(const ['external_oblique_l', 'external_oblique_r']);
  }
  if (value.contains('bicep')) {
    return byPrefixes(const ['biceps_brachii']);
  }
  if (value.contains('tricep')) {
    return byPrefixes(const ['triceps_brachii']);
  }
  if (value.contains('forearm') ||
      value.contains('wrist') ||
      value.contains('hand')) {
    return {
      for (final muscle in MuscleCatalog.all)
        if (muscle.group == MuscleGroup.arms &&
            (muscle.id.contains('radialis') ||
                muscle.id.contains('flexor') ||
                muscle.id.contains('extensor') ||
                muscle.id.contains('brachioradialis')))
          muscle,
    };
  }
  if (value.contains('delt') || value == 'shoulder' || value == 'shoulders') {
    return {
      for (final muscle in MuscleCatalog.all)
        if (muscle.group == MuscleGroup.shoulders &&
            muscle.id.contains('deltoid'))
          muscle,
    };
  }
  if (value.contains('trap')) {
    return byPrefixes(const ['trapezius']);
  }
  if (value.contains('lat')) {
    return byPrefixes(const ['latissimus']);
  }
  if (value.contains('rotator')) {
    return byPrefixes(const ['infraspinatus']);
  }
  if (value.contains('upper back') || value.contains('rhomboid')) {
    return {
      ...byPrefixes(const ['trapezius', 'latissimus', 'infraspinatus']),
    };
  }
  if (value.contains('lower back') ||
      value.contains('spine') ||
      value.contains('erector')) {
    // The atlas artwork does not expose erector spinae paths.
    return const {};
  }
  if (value.contains('glute') || value.contains('abduct')) {
    return fromGroup(MuscleGroup.glutes);
  }
  if (value.contains('quad') || value.contains('quadricep')) {
    return byPrefixes(const ['rectus_femoris', 'vastus_']);
  }
  if (value.contains('hamstring')) {
    return fromGroup(MuscleGroup.hamstrings);
  }
  if (value.contains('calf') || value.contains('calve')) {
    return byPrefixes(const ['gastrocnemius', 'soleus']);
  }
  if (value.contains('adductor')) {
    return fromGroup(MuscleGroup.adductors);
  }
  if (value.contains('hip flexor') || value.contains('iliopsoas')) {
    // Not drawn in the current atlas layer.
    return const {};
  }
  if (value.contains('neck') || value.contains('levator')) {
    return {
      ...fromGroup(MuscleGroup.neck),
      ...byPrefixes(const ['trapezius_upper']),
    };
  }
  if (value.contains('serratus') ||
      value.contains('cardiovascular') ||
      value.contains('heart')) {
    return const {};
  }
  // Some dataset entries use plural/irregular labels; try a broad group match.
  final group = MuscleGroup.tryFromString(value);
  if (group != null) return fromGroup(group);
  final direct = MuscleCatalog.tryById(value);
  if (direct != null) return {direct};
  // Last resort: match the atlas display names / aliases.
  return {
    for (final muscle in MuscleCatalog.all)
      if (muscle.searchTokens.any(
        (token) => token.toLowerCase().contains(value),
      ))
        muscle,
  };
}

String atlasMuscleLabel(MuscleInfo muscle, String locale) {
  if (locale != 'zh') return muscle.displayName;
  const labels = <String, String>{
    'pectoralis_major': '胸大肌',
    'anterior_deltoid': '三角肌前束',
    'lateral_deltoid': '三角肌中束',
    'posterior_deltoid': '三角肌后束',
    'biceps_brachii': '肱二头肌',
    'triceps_brachii': '肱三头肌',
    'brachioradialis': '肱桡肌',
    'flexor': '前臂屈肌',
    'extensor': '前臂伸肌',
    'latissimus_dorsi': '背阔肌',
    'infraspinatus': '冈下肌',
    'trapezius_upper': '斜方肌上束',
    'trapezius_middle': '斜方肌中束',
    'trapezius_lower': '斜方肌下束',
    'rectus_abdominis': '腹直肌',
    'external_oblique': '腹外斜肌',
    'gluteus_maximus': '臀大肌',
    'gluteus_medius': '臀中肌',
    'rectus_femoris': '股直肌',
    'vastus_lateralis': '股外侧肌',
    'vastus_medialis': '股内侧肌',
    'sartorius': '缝匠肌',
    'biceps_femoris': '股二头肌',
    'semitendinosus': '半腱肌',
    'semimembranosus': '半膜肌',
    'gastrocnemius': '腓肠肌',
    'soleus': '比目鱼肌',
    'tibialis_anterior': '胫骨前肌',
    'adductor_magnus': '大收肌',
    'adductor_longus': '长收肌',
    'pectineus': '耻骨肌',
    'sternocleidomastoid': '胸锁乳突肌',
    'platysma': '颈阔肌',
    'sternohyoid': '胸骨舌骨肌',
    'gracilis': '股薄肌',
    'iliotibial_tract': '髂胫束',
  };
  for (final entry in labels.entries) {
    if (muscle.id.startsWith(entry.key)) return entry.value;
  }
  return muscle.displayName;
}

String _cleanDisplayName(MuscleInfo muscle) {
  return muscle.displayName
      .replaceAll(' — Left', '')
      .replaceAll(' — Right', '')
      .replaceAll(' - Left', '')
      .replaceAll(' - Right', '')
      .trim();
}
