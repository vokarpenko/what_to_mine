import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/utils/scheduler/daily_profitability_check.dart';

void main() {
  late SharedPreferences preferences;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    now = DateTime.utc(2026, 10, 28, 12);
  });

  DailyProfitabilityCheck check() =>
      DailyProfitabilityCheck(preferences: preferences, now: () => now);

  test('checks once in 24 hours including after instance restart', () async {
    var calls = 0;
    Future<void> work() async {
      calls++;
    }

    await check().run(work);
    now = now.add(const Duration(hours: 23, minutes: 59));
    await check().run(work);
    expect(calls, 1);
    now = now.add(const Duration(minutes: 1));
    await check().run(work);
    expect(calls, 2);
  });

  test('duplicate callbacks share the same daily check', () async {
    var calls = 0;
    final finished = Completer<void>();
    Future<void> work() async {
      calls++;
      await finished.future;
    }

    final pending = [check().run(work), check().run(work)];
    await Future<void>.delayed(Duration.zero);
    finished.complete();
    await Future.wait(pending);
    expect(calls, 1);
  });

  test(
    'failed checks do not repeatedly spend quota during the same day',
    () async {
      var calls = 0;
      await expectLater(
        check().run(() async {
          calls++;
          throw StateError('offline');
        }),
        throwsStateError,
      );
      await check().run(() async {
        calls++;
      });
      expect(calls, 1);
    },
  );
}
