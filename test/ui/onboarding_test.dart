import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/ui/screens/introduction/intro_screen.dart';
import 'package:what_to_mine/src/ui/theme/app_theme_data.dart';

void main() {
  testWidgets(
    'onboarding fits compact Russian layout and validates electricity',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('ru')],
          startLocale: const Locale('ru'),
          path: 'assets/translations',
          child: Builder(
            builder: (context) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppThemeData.lightTheme,
              home: const IntroScreen(),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      final field = find.byType(TextFormField);
      await tester.ensureVisible(field);
      await tester.enterText(field, '-1');
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('invalid_electricity'.tr()), findsOneWidget);
      expect(find.byType(IntroScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
