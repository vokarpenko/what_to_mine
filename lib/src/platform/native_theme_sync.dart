import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Flutter ThemeMode indices: system=0, light=1, dark=2.
abstract final class NativeThemeSync {
  static const channel = MethodChannel('ru.vokarpenko.what_to_mine/theme');

  static Future<void> apply(int mode) async {
    if (mode < 0 || mode > 2) throw ArgumentError.value(mode, 'mode');
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await channel.invokeMethod<void>('setThemeMode', {'mode': mode});
    } on MissingPluginException {
      // Widget tests and non-activity Flutter engines have no Android window.
    } on PlatformException catch (error) {
      // A vendor-specific native failure must not prevent Flutter from opening
      // with the user's saved theme.
      debugPrint('Native theme synchronization failed: ${error.code}');
    }
  }
}
