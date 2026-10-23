import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/app/providers.dart';
import 'package:force_trace/core/theme/app_theme.dart';
import 'package:force_trace/data/models/models.dart';
import 'package:force_trace/data/settings/settings.dart';
import 'package:force_trace/features/live/live_hud_page.dart';
import 'package:force_trace/services/camera_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/camera');

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('camera startup is shared and safe when the page closes before it completes', () async {
    var queries = 0;
    final pending = Completer<List<Object>>();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'availableCameras') {
        queries++;
        return pending.future;
      }
      return null;
    });
    final session = CameraSession();
    final first = session.enable();
    final second = session.enable();
    expect(identical(first, second), isTrue);
    session.dispose();
    pending.complete([]);
    await Future.wait([first, second]);
    expect(queries, 1);
    expect(session.active, isFalse);
  });

  testWidgets(
    'entering vision tracking requests the camera without a manual toggle',
    (tester) async {
      var queries = 0;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'availableCameras') {
          queries++;
          return [];
        }
        return null;
      });
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsController(
        await SharedPreferences.getInstance(),
      );
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsProvider.overrideWith((ref) => settings)],
          child: MaterialApp(
            theme: AppTheme.dark(),
            locale: const Locale('zh'),
            supportedLocales: const [Locale('zh'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: const LiveHudPage(
              exercise: Exercise(
                id: '0025',
                name: 'barbell bench press',
                localName: '杠铃卧推',
                category: 'chest',
                bodyPart: 'chest',
                equipment: 'barbell',
                target: 'pectorals',
                secondaryMuscles: ['triceps'],
                tier: ExerciseTier.vbt,
                mediaId: 'EIeI8Vf',
              ),
              targetReps: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(queries, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
