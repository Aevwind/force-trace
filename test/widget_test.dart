import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_trace/core/theme/app_theme.dart';
import 'package:force_trace/core/widgets/common.dart';

void main() {
  testWidgets('Tier badge renders the localized VBT label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('zh'),
        supportedLocales: const [Locale('zh'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const Scaffold(body: Center(child: TierBadge(tierValue: 1))),
      ),
    );

    expect(find.text('VBT'), findsOneWidget);
    expect(find.text('力迹'), findsNothing);
  });

  testWidgets('Tier badge switches to the English label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('en'),
        supportedLocales: const [Locale('zh'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const Scaffold(body: Center(child: TierBadge(tierValue: 3))),
      ),
    );

    expect(find.text('Volume'), findsOneWidget);
  });
}
