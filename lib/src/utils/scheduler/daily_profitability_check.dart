import 'package:shared_preferences/shared_preferences.dart';

// Android can deliver extra fetch callbacks around process restarts. Claim
// today's attempt before doing network work, including when that work fails.
class DailyProfitabilityCheck {
  static const interval = Duration(days: 1);
  static const _lastAttemptKey = 'daily_profitability_check_attempt';
  static Future<void>? _running;

  final SharedPreferences _preferences;
  final DateTime Function() _now;

  DailyProfitabilityCheck({
    required this._preferences,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  Future<void> run(Future<void> Function() check) async {
    final running = _running;
    if (running != null) return running;
    final future = _run(check);
    _running = future;
    try {
      await future;
    } finally {
      _running = null;
    }
  }

  Future<void> _run(Future<void> Function() check) async {
    await _preferences.reload();
    final now = _now();
    final previous = _preferences.getInt(_lastAttemptKey);
    if (previous != null &&
        now.millisecondsSinceEpoch - previous < interval.inMilliseconds) {
      return;
    }
    await _preferences.setInt(_lastAttemptKey, now.millisecondsSinceEpoch);
    await check();
  }
}
