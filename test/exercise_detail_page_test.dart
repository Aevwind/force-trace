import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/app/providers.dart';
import 'package:force_trace/core/theme/app_theme.dart';
import 'package:force_trace/data/models/models.dart';
import 'package:force_trace/features/library/exercise_detail_page.dart';
import 'package:force_trace/features/library/widgets/exercise_preview.dart';

const _exercise = Exercise(
  id: '0025',
  name: 'barbell bench press',
  localName: '杠铃卧推',
  category: 'chest',
  bodyPart: 'chest',
  equipment: 'barbell',
  target: 'pectorals',
  secondaryMuscles: ['triceps', 'delts'],
  tier: ExerciseTier.vbt,
  mediaId: 'EIeI8Vf',
);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.dark(),
  locale: const Locale('zh'),
  supportedLocales: const [Locale('zh'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: child,
);

void main() {
  testWidgets(
    'preview defaults to a still image and switches to GIF on demand',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: SingleChildScrollView(
              child: ExercisePreview(exercise: _exercise),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final image = find.descendant(
        of: find.byType(ExercisePreview),
        matching: find.byType(Image),
      );
      String url() => (tester.widget<Image>(image).image as NetworkImage).url;
      expect(url(), endsWith('/images/0025-EIeI8Vf.jpg'));
      await tester.tap(find.text('动图'));
      await tester.pumpAndSettle();
      expect(url(), endsWith('/videos/0025-EIeI8Vf.gif'));
      // A failed remote request keeps the mode control and retry available.
      expect(find.text('重试'), findsOneWidget);
      await tester.tap(find.text('图片'));
      await tester.pumpAndSettle();
      expect(url(), endsWith('/images/0025-EIeI8Vf.jpg'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'detail actions fit on a narrow phone without wrapping or clipping',
    (tester) async {
      tester.view.physicalSize = const Size(320, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseDetailProvider.overrideWith(
              (ref, id) async => const ExerciseDetail(
                exercise: _exercise,
                steps: {
                  'zh': ['缓慢下放，再向上推起。'],
                },
              ),
            ),
          ],
          child: _app(const ExerciseDetailPage(exerciseId: '0025')),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in ['加入今日训练', '开始视觉追踪']) {
        final text = find.text(label);
        final paragraph = tester.renderObject<RenderParagraph>(text);
        expect(
          paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: label.length),
          ),
          hasLength(1),
        );
        final button = find
            .ancestor(
              of: text,
              matching: find.byWidgetPredicate(
                (widget) => widget is ButtonStyleButton,
              ),
            )
            .first;
        final textRect = tester.getRect(text);
        final buttonRect = tester.getRect(button);
        expect(textRect.left, greaterThanOrEqualTo(buttonRect.left));
        expect(textRect.right, lessThanOrEqualTo(buttonRect.right));
      }
      expect(find.byType(ExercisePreview), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
