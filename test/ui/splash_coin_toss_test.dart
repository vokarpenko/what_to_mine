import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_coin_toss.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_screen.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_view_model.dart';
import 'package:what_to_mine/src/ui/theme/app_theme_data.dart';

class ControlledSplash extends SplashViewModel {
  final _routes = StreamController<String>();
  final _errors = StreamController<String>();
  final bool readyImmediately;
  final bool readyOnRetry;
  bool disposed = false;
  int retries = 0;

  ControlledSplash({this.readyImmediately = false, this.readyOnRetry = false});
  @override
  Stream<String> get openNextScreen => _routes.stream;
  @override
  Stream<String> get errorMessage => _errors.stream;
  @override
  void onViewInitState() {
    if (readyImmediately) ready();
  }

  void ready() {
    if (!disposed) _routes.add('/ready');
  }

  void fail() => _errors.add('Test network failure');
  @override
  void getData() {
    retries++;
    if (readyOnRetry) ready();
  }

  @override
  void onViewDispose() {
    disposed = true;
    _routes.close();
    _errors.close();
    super.onViewDispose();
  }
}

class SplashTranslations extends AssetLoader {
  const SplashTranslations();
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => {
    'error': 'Error',
    'ok': 'OK',
    'loading_markets': 'Loading markets',
  };
}

Future<void> showSplash(WidgetTester tester, ControlledSplash model) async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      startLocale: const Locale('en'),
      path: 'assets/translations',
      assetLoader: const SplashTranslations(),
      child: Builder(
        builder: (context) => MaterialApp(
          theme: AppThemeData.lightTheme,
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          home: SplashScreen(viewModel: model),
          routes: {
            '/ready': (_) => const Scaffold(body: Text('Dashboard ready')),
          },
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/images/splash_coin.png'),
      tester.element(find.byType(SplashScreen)),
    ),
  );
  await tester.pump();
  await tester.pump(); // first ticker frame establishes the animation clock
}

void main() {
  testWidgets(
    'fast data waits for the full toss before opening the next screen',
    (tester) async {
      final model = ControlledSplash(readyImmediately: true);
      await showSplash(tester, model);
      final start = tester.getCenter(find.byKey(const ValueKey('splash_coin')));
      await tester.pump(const Duration(milliseconds: 650));
      final airborne = tester.getCenter(
        find.byKey(const ValueKey('splash_coin')),
      );
      expect(airborne.dy, lessThan(start.dy - 70));
      expect(find.text('Dashboard ready'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Dashboard ready'), findsNothing);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard ready'), findsOneWidget);
      expect(model.disposed, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('slow data keeps the landed coin in its exact original pose', (
    tester,
  ) async {
    final model = ControlledSplash();
    await showSplash(tester, model);
    final coin = find.byKey(const ValueKey('splash_coin'));
    final front = find.byKey(const ValueKey('splash_coin_front'));
    final baseline = tester.getCenter(coin);
    final initialTransform = tester
        .widget<Transform>(front)
        .transform
        .storage
        .toList();
    await tester.pump(SplashCoinToss.duration);
    expect(tester.getCenter(coin).dx, closeTo(baseline.dx, .01));
    expect(tester.getCenter(coin).dy, closeTo(baseline.dy, .01));
    expect(
      tester.widget<Transform>(front).transform.storage,
      orderedEquals(initialTransform),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.getCenter(coin).dy, closeTo(baseline.dy, .01));
    model.ready();
    await tester.pumpAndSettle();
    expect(find.text('Dashboard ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'system reduce-motion skips the toss without delaying ready data',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await showSplash(tester, ControlledSplash(readyImmediately: true));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard ready'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disposing during flight cancels animation and late navigation', (
    tester,
  ) async {
    final model = ControlledSplash();
    await showSplash(tester, model);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox.shrink());
    model.ready();
    await tester.pump(const Duration(seconds: 3));
    expect(model.disposed, isTrue);
    expect(find.text('Dashboard ready'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'load errors remain visible and a retry after landing can navigate',
    (tester) async {
      final model = ControlledSplash(readyOnRetry: true);
      await showSplash(tester, model);
      model.fail();
      await tester.pump();
      await tester.pump(SplashCoinToss.duration);
      expect(find.text('Test network failure'), findsOneWidget);
      expect(find.text('Dashboard ready'), findsNothing);
      await tester.tap(find.text('OK'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(model.retries, 1);
      expect(find.text('Dashboard ready'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
