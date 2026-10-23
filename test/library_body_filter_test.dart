import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/app/providers.dart';
import 'package:force_trace/core/theme/app_theme.dart';
import 'package:force_trace/data/models/models.dart';
import 'package:force_trace/features/library/library_page.dart';
import 'package:force_trace/features/library/widgets/body_category_filter.dart';
import 'package:force_trace/features/library/widgets/exercise_card.dart';

Exercise _exercise(
  String id,
  String name,
  String category, {
  String equipment = 'barbell',
  int tier = 1,
}) => Exercise(
  id: id,
  name: name,
  localName: name,
  category: category,
  bodyPart: category,
  equipment: equipment,
  target: category,
  secondaryMuscles: const [],
  tier: ExerciseTier.fromValue(tier),
  mediaId: '',
);

final _catalog = [
  _exercise('1', 'barbell bench press', 'chest'),
  _exercise(
    '2',
    'dumbbell incline press',
    'chest',
    equipment: 'dumbbell',
    tier: 2,
  ),
  _exercise('3', 'barbell shoulder press', 'shoulders'),
  _exercise('4', 'dumbbell curl', 'upper arms', equipment: 'dumbbell', tier: 2),
  _exercise('5', 'barbell bent over row', 'back'),
  _exercise('6', 'barbell calf raise', 'lower legs'),
  _exercise('7', 'barbell squat', 'upper legs'),
];

const _initialFilter = LibraryFilter(
  query: 'press',
  equipment: 'barbell',
  tiers: {1},
);

Future<ProviderContainer> _openLibrary(
  WidgetTester tester, {
  double width = 400,
}) async {
  await tester.runAsync(() async {
    await Future.wait([
      AtlasAsset.musclesFront.loadSvg(),
      AtlasAsset.musclesBack.loadSvg(),
    ]);
  });
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        catalogProvider.overrideWith((ref) async => _catalog),
        libraryFilterProvider.overrideWith((ref) => _initialFilter),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('zh'),
        supportedLocales: const [Locale('zh'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const Scaffold(body: LibraryPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(LibraryPage)));
}

Finder _atlas(AtlasAsset view) => find.byWidgetPredicate(
  (widget) => widget is BodyAtlasView<MuscleInfo> && widget.view == view,
);

Future<void> _tapChest(WidgetTester tester) async {
  // The atlas's hit-test data loads separately from SVG painting. Complete that
  // asset future in the real async zone before sending an actual pointer tap.
  final loaders = find
      .descendant(
        of: _atlas(AtlasAsset.musclesFront),
        matching: find.byWidgetPredicate((widget) => widget is FutureBuilder),
      )
      .evaluate()
      .map((element) => (element.widget as FutureBuilder).future)
      .whereType<Future<Object?>>()
      .toList();
  await tester.runAsync(() async => Future.wait(loaders));
  await tester.pumpAndSettle();
  final rect = tester.getRect(_atlas(AtlasAsset.musclesFront));
  // A point inside the left pectoral of the bundled 587 x 1137 front SVG.
  final scale = math.min(rect.width / 587, rect.height / 1137);
  final origin =
      rect.topLeft +
      Offset((rect.width - 587 * scale) / 2, (rect.height - 1137 * scale) / 2);
  await tester.tapAt(origin + Offset(350 * scale, 255 * scale));
  await tester.pumpAndSettle();
}

void main() {
  test('atlas regions map consistently to body categories on both sides', () {
    const expected = {
      'pectoralis_major_l': 'chest',
      'pectoralis_major_r': 'chest',
      'biceps_brachii_caput_longum_l': 'upper arms',
      'triceps_brachii_caput_longum_r': 'upper arms',
      'brachioradialis_r': 'lower arms',
      'extensor_digitorum_l': 'lower arms',
      'rectus_femoris_l': 'upper legs',
      'biceps_femoris_r': 'upper legs',
      'gluteus_maximus_l': 'upper legs',
      'gastrocnemius_l': 'lower legs',
      'tibialis_anterior_r': 'lower legs',
      'trapezius_upper_l': 'back',
      'latissimus_dorsi_r': 'back',
      'posterior_deltoid_l': 'shoulders',
      'rectus_abdominis_1': 'waist',
      'sternocleidomastoid_l': 'neck',
    };
    for (final entry in expected.entries) {
      expect(
        categoryForAtlasMuscle(MuscleCatalog.tryById(entry.key)!),
        entry.value,
        reason: entry.key,
      );
    }
  });

  testWidgets(
    'touching the model toggles category while preserving other filters',
    (tester) async {
      final container = await _openLibrary(tester);
      expect(
        container.read(filteredExercisesProvider).valueOrNull,
        hasLength(2),
      );
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await _tapChest(tester);
      final filter = container.read(libraryFilterProvider);
      expect(filter.category, 'chest');
      expect(filter.query, 'press');
      expect(filter.equipment, 'barbell');
      expect(filter.tiers, {1});
      expect(find.text('完成 · 1 个动作'), findsOneWidget);
      final chestChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '胸部'),
      );
      expect(chestChip.selected, isTrue);
      for (final view in AtlasAsset.values) {
        final colors = tester
            .widget<BodyAtlasView<MuscleInfo>>(_atlas(view))
            .colorMapping!;
        expect(colors, isNotEmpty);
        expect(
          colors.keys.every(
            (muscle) => categoryForAtlasMuscle(muscle) == 'chest',
          ),
          isTrue,
        );
      }
      await _tapChest(tester);
      expect(container.read(libraryFilterProvider).category, isEmpty);
      expect(find.text('完成 · 2 个动作'), findsOneWidget);
      await _tapChest(tester);
      await tester.tap(find.widgetWithText(FilledButton, '完成 · 1 个动作'));
      await tester.pumpAndSettle();
      final cards = tester.widgetList<ExerciseListCard>(
        find.byType(ExerciseListCard),
      );
      expect(cards.map((card) => card.exercise.id), ['1']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'chips highlight both views and reset clears the model and search on a narrow screen',
    (tester) async {
      final container = await _openLibrary(tester, width: 320);
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      final chip = find.widgetWithText(ChoiceChip, '背部');
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(container.read(libraryFilterProvider).category, 'back');
      expect(find.text('完成 · 0 个动作'), findsOneWidget);
      for (final view in AtlasAsset.values) {
        final colors = tester
            .widget<BodyAtlasView<MuscleInfo>>(_atlas(view))
            .colorMapping!;
        expect(colors, isNotEmpty);
        expect(
          colors.keys.every(
            (muscle) => categoryForAtlasMuscle(muscle) == 'back',
          ),
          isTrue,
        );
      }
      await tester.tap(find.text('重置'));
      await tester.pumpAndSettle();
      expect(container.read(libraryFilterProvider).isActive, isFalse);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('完成 · 7 个动作'), findsOneWidget);
      for (final view in AtlasAsset.values) {
        expect(
          tester.widget<BodyAtlasView<MuscleInfo>>(_atlas(view)).colorMapping,
          isEmpty,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}
