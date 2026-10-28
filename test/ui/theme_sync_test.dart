import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/domain/settings.dart';
import 'package:what_to_mine/src/logic/settings_service.dart';
import 'package:what_to_mine/src/platform/native_theme_sync.dart';
import 'package:what_to_mine/src/ui/theme/app_theme_data.dart';
import 'package:what_to_mine/src/ui/theme/theme_bootstrap.dart';
import 'package:what_to_mine/src/ui/theme/theme_config.dart';
import '../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    currentTheme.switchTheme(ThemeMode.system);
    messenger.setMockMethodCallHandler(NativeThemeSync.channel, (call) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(
    () => messenger.setMockMethodCallHandler(NativeThemeSync.channel, null),
  );

  for (final (mode, phone, expected) in [
    (ThemeMode.light, Brightness.dark, Brightness.light),
    (ThemeMode.dark, Brightness.light, Brightness.dark),
    (ThemeMode.system, Brightness.dark, Brightness.dark),
    (ThemeMode.system, Brightness.light, Brightness.light),
  ]) {
    testWidgets(
      'first Flutter frame honors ${mode.name} with phone ${phone.name}',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = phone;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        SharedPreferences.setMockInitialValues({
          's': Settings(themeIndex: mode.index).toJsonString(),
        });
        await restoreAppTheme();
        expect(currentTheme.currentTheme(), mode);
        expect(calls.single.method, 'setThemeMode');
        expect(calls.single.arguments, {'mode': mode.index});
        await tester.pumpWidget(
          MaterialApp(
            themeMode: currentTheme.currentTheme(),
            theme: AppThemeData.lightTheme,
            darkTheme: AppThemeData.darkTheme,
            home: const Scaffold(body: Text('First frame')),
          ),
        );
        expect(
          Theme.of(tester.element(find.text('First frame'))).brightness,
          expected,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  test('new installs and invalid saved appearance follow the phone', () async {
    expect(Settings().themeIndex, ThemeMode.system.index);
    for (final raw in [
      null,
      '{broken',
      '{"themeIndex":99}',
      '{"themeIndex":"dark"}',
      'null',
    ]) {
      SharedPreferences.setMockInitialValues({'s': ?raw});
      currentTheme.switchTheme(ThemeMode.dark);
      await restoreAppTheme();
      expect(currentTheme.currentTheme(), ThemeMode.system);
      expect(calls.last.arguments, {'mode': 0});
    }
  });

  test(
    'theme changes persist Flutter settings before updating Android',
    () async {
      final gateway = MockGateway();
      var saved = false;
      when(gateway.getSettings()).thenAnswer((_) async => Settings());
      when(gateway.setSettings(any)).thenAnswer((_) async {
        saved = true;
      });
      messenger.setMockMethodCallHandler(NativeThemeSync.channel, (call) async {
        expect(saved, isTrue);
        calls.add(call);
        return null;
      });
      final service = SettingsService(gateway: gateway);
      for (final mode in ThemeMode.values) {
        saved = false;
        await service.setThemeIndex(mode.index);
        expect(calls.last.arguments, {'mode': mode.index});
      }
      expect(calls.length, 3);
      await expectLater(service.setThemeIndex(42), throwsArgumentError);
      expect(calls.length, 3);
    },
  );

  test(
    'a missing native channel does not block restoring the Flutter theme',
    () async {
      messenger.setMockMethodCallHandler(NativeThemeSync.channel, null);
      SharedPreferences.setMockInitialValues({
        's': Settings(themeIndex: 2).toJsonString(),
      });
      await restoreAppTheme();
      expect(currentTheme.currentTheme(), ThemeMode.dark);
    },
  );

  test(
    'a native platform error does not prevent Flutter from opening',
    () async {
      messenger.setMockMethodCallHandler(NativeThemeSync.channel, (_) async {
        throw PlatformException(code: 'device_error');
      });
      SharedPreferences.setMockInitialValues({
        's': Settings(themeIndex: 1).toJsonString(),
      });
      await restoreAppTheme();
      expect(currentTheme.currentTheme(), ThemeMode.light);
    },
  );
}
