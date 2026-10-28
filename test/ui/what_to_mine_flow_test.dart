import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_mine/src/app.dart';
import 'package:what_to_mine/src/data/client/what_to_mine_client.dart';
import 'package:what_to_mine/src/data/client/btc_usd_rate_client.dart';
import 'package:what_to_mine/src/data/db/entities/used_gpu_entity.dart';
import 'package:what_to_mine/src/data/db/entities/user_hash_algorithm_entity.dart';
import 'package:what_to_mine/src/domain/settings.dart';
import 'package:what_to_mine/src/logic/favorites_store.dart';
import 'package:what_to_mine/src/logic/services.dart';
import 'package:what_to_mine/src/ui/widgets/earnings_widget.dart';
import 'package:what_to_mine/src/ui/widgets/hashrate_widget.dart';
import 'package:what_to_mine/src/ui/widgets/crypto_currency_widget.dart';

import '../fixtures/what_to_mine_fixtures.dart';
import '../mocks.mocks.dart';
import '../test_objects_factory.dart';
import 'package:what_to_mine/src/ui/screens/gpu/gpu_list_screen.dart';
import 'package:what_to_mine/src/ui/screens/gpu/gpu_model_picker.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/hashrate_screen.dart';
import 'package:what_to_mine/src/ui/screens/splash/splash_screen.dart';

void main() {
  testWidgets(
    'saved rig opens earnings, USD prices, current GPU catalog, and hashrates',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        's': Settings(isFirstRun: false, themeIndex: 1).toJsonString(),
      });
      await EasyLocalization.ensureInitialized();
      final preferences = await SharedPreferences.getInstance();
      var requests = 0;
      final api = WhatToMineClient(
        preferences: preferences,
        apiKey: 'test-token',
        client: MockClient((request) async {
          requests++;
          final data = switch (request.url.pathSegments.last) {
            'gpus' => wtmGpus,
            'coins' => wtmCoins,
            'algorithms' => wtmAlgorithms,
            'calculate' => [
              ...wtmCalculation,
              {
                'id': 162,
                'tag': 'ETC',
                'name': 'Ethereum Classic',
                'estimated_rewards': '0.01',
                'revenue': '0.1',
                'profit': '-0.2',
              },
            ],
            _ => throw StateError('Unexpected endpoint'),
          };
          return http.Response(jsonEncode(data), 200);
        }),
      );
      final used = TestObjectsFactory.createUsedGpuGtx1080(1);
      final database = MockAppDatabase();
      final gpuDao = MockUsedGpuDao();
      when(database.usedGpuDao).thenReturn(gpuDao);
      when(gpuDao.selectAll()).thenAnswer((_) async => [UsedGpuEntity(used)]);
      final hashDao = MockUserHashAlgorithmDao();
      final savedHashes = <String, UserHashAlgorithmEntity>{};
      when(database.userHashAlgorithmDao).thenReturn(hashDao);
      when(
        hashDao.selectAll(),
      ).thenAnswer((_) async => savedHashes.values.toList());
      when(hashDao.insert(any)).thenAnswer((call) async {
        final entity =
            call.positionalArguments.single as UserHashAlgorithmEntity;
        savedHashes[entity.id] = entity;
      });
      var exchangeRequests = 0;
      final exchangeRates = BtcUsdRateClient(
        preferences: preferences,
        client: MockClient((request) async {
          exchangeRequests++;
          expect(request.url.host, 'api.coinbase.com');
          return http.Response(
            jsonEncode({
              'data': {
                'currency': 'BTC',
                'rates': {'USD': '100000'},
              },
            }),
            200,
          );
        }),
      );
      await initializeApp(
        client: api,
        appDatabase: database,
        exchangeRates: exchangeRates,
      );

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ru')],
          path: 'assets/translations',
          startLocale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          child: const App(),
        ),
      );
      // Localization and image decoding use real I/O. Finish the native-to-
      // Flutter image handoff before advancing the toss's simulated clock.
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/splash_coin.png'),
          tester.element(find.byType(SplashScreen)),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('−\$0.09'), findsWidgets);
      expect(find.text('−\$2.70'), findsWidgets);
      expect(tester.takeException(), isNull);

      expect(requests, 2); // coins + calculate; no eager catalogs
      expect(find.byType(GpuListScreen), findsNothing);
      expect(find.byType(HashrateScreen), findsNothing);
      expect(
        exchangeRequests,
        0,
      ); // no exchange-rate request until Prices opens
      final callsAfterStartup = requests;
      await tester.tap(find.text('Prices'));
      await tester.pumpAndSettle();
      expect(find.text('USD'), findsOneWidget);
      expect(find.text(r'$0.0100'), findsOneWidget);
      expect(exchangeRequests, 1);
      expect(find.text('Ravencoin'), findsOneWidget);
      expect(requests, callsAfterStartup);

      // Favorites pin above the alphabetic order; search stays local.
      expect(
        tester
            .widgetList<CryptoCurrencyWidget>(find.byType(CryptoCurrencyWidget))
            .map((card) => card.currency.coin),
        ['ETC', 'RVN'],
      );
      await tester.tap(find.byKey(const ValueKey('favorite_prices_234')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<CryptoCurrencyWidget>(find.byType(CryptoCurrencyWidget))
            .map((card) => card.currency.coin),
        ['RVN', 'ETC'],
      );
      expect(preferences.getStringList('favorites.v1.prices'), ['234']);
      expect(Services.favorites.ids(FavoriteList.earnings), isEmpty);
      final search = find.byKey(const ValueKey('coin_search'));
      await tester.enterText(search, 'eThErEuM');
      await tester.pumpAndSettle();
      expect(find.byType(CryptoCurrencyWidget), findsOneWidget);
      expect(find.text('Ethereum Classic'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Favorites · 1'));
      await tester.pumpAndSettle();
      expect(find.byType(CryptoCurrencyWidget), findsNothing);
      await tester.enterText(search, 'kawpow');
      await tester.pumpAndSettle();
      expect(find.byType(CryptoCurrencyWidget), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(requests, callsAfterStartup);
      expect(exchangeRequests, 1);

      await tester.tap(find.widgetWithText(NavigationDestination, 'Earnings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('favorite_earnings_162')),
        250,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('favorite_earnings_162')));
      await tester.pumpAndSettle();
      final cards = tester.widgetList<EarningsWidget>(
        find.byType(EarningsWidget),
      );
      expect(cards.first.earnings.cryptoCurrency.coin, 'ETC');
      expect(preferences.getStringList('favorites.v1.earnings'), ['162']);
      await tester.ensureVisible(search);
      await tester.enterText(search, 'RVN');
      await tester.pumpAndSettle();
      expect(find.byType(EarningsWidget), findsOneWidget);
      expect(
        tester
            .widget<EarningsWidget>(find.byType(EarningsWidget))
            .earnings
            .cryptoCurrency
            .coin,
        'RVN',
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Favorites · 1'));
      await tester.pumpAndSettle();
      expect(find.byType(EarningsWidget), findsNothing);
      expect(requests, callsAfterStartup);

      await tester.tap(find.widgetWithText(NavigationDestination, 'My rig'));
      await tester.pumpAndSettle();
      expect(find.text('nvidea gtx 1080'), findsOneWidget);
      expect(requests, callsAfterStartup);
      await tester.tap(find.byKey(const ValueKey('add_gpu')));
      await tester.pumpAndSettle();
      expect(find.byType(AddGpuSheet), findsOneWidget);
      expect(requests, callsAfterStartup + 1);
      await tester.tap(find.byKey(const ValueKey('select_gpu_model')));
      await tester.pumpAndSettle();
      expect(find.byType(GpuModelPicker), findsOneWidget);
      expect(find.text('AMD'), findsOneWidget);
      expect(find.text('OTHER'), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('gpu_model_search')),
        '7900',
      );
      await tester.pumpAndSettle();
      expect(find.text('no_matches'.tr()), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'AMD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('gpu_option_wtm:gpu:2')));
      await tester.pumpAndSettle();
      expect(find.byType(GpuModelPicker), findsNothing);
      expect(find.text('Radeon RX 7900 XTX'), findsOneWidget);
      // Closing the picker without choosing preserves the current model.
      await tester.tap(find.byKey(const ValueKey('select_gpu_model')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Radeon RX 7900 XTX'), findsOneWidget);
      expect(requests, callsAfterStartup + 1);
      Navigator.of(tester.element(find.byType(AddGpuSheet))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hashrates'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hashrate_search')), findsOneWidget);
      final inputs = find.descendant(
        of: find.byKey(const ValueKey('hashrate_Etchash')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(inputs.first);
      await tester.enterText(inputs.first, '12.5');
      await tester.pumpAndSettle();
      await tester.enterText(inputs.last, '200');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(inputs.first).controller!.text, '12.5');
      expect(tester.widget<TextField>(inputs.last).controller!.text, '200');
      expect(find.text('Save changes'), findsOneWidget);
      expect(tester.widget<TextField>(inputs.last).focusNode!.hasFocus, isTrue);
      await tester.tapAt(
        tester.getTopLeft(find.byKey(const ValueKey('hashrate_Etchash'))) +
            const Offset(12, 12),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(inputs.last).focusNode!.hasFocus,
        isFalse,
      );
      expect(tester.testTextInput.isVisible, isFalse);
      expect(tester.widget<TextField>(inputs.last).controller!.text, '200');
      expect(requests, callsAfterStartup + 1);
      final hashSearch = find.byKey(const ValueKey('hashrate_search'));
      await tester.scrollUntilVisible(
        hashSearch,
        -250,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(hashSearch, 'kaWPoW');
      await tester.pumpAndSettle();
      expect(find.byType(HashrateWidget), findsOneWidget);
      final kawpowInputs = find.descendant(
        of: find.byKey(const ValueKey('hashrate_KawPow')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(kawpowInputs.first);
      await tester.enterText(kawpowInputs.first, '7.25');
      await tester.enterText(kawpowInputs.last, '120');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('favorite_hashrates_kawpow')));
      await tester.pumpAndSettle();
      expect(preferences.getStringList('favorites.v1.hashrates'), ['kawpow']);
      expect(Services.favorites.ids(FavoriteList.earnings), {'162'});
      await tester.scrollUntilVisible(
        hashSearch,
        -250,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<HashrateWidget>(find.byType(HashrateWidget))
            .first
            .algorithm
            .name,
        'KawPow',
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Favorites · 1'));
      await tester.pumpAndSettle();
      expect(find.byType(HashrateWidget), findsOneWidget);
      await tester.enterText(hashSearch, 'Etchash');
      await tester.pumpAndSettle();
      expect(find.byType(HashrateWidget), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, 'All algorithms'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(inputs.first).controller!.text, '12.5');
      expect(tester.widget<TextField>(inputs.last).controller!.text, '200');
      await tester.enterText(hashSearch, 'nonexistent');
      await tester.pumpAndSettle();
      expect(find.byType(HashrateWidget), findsNothing);
      await tester.enterText(hashSearch, 'KawPow');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(kawpowInputs.first).controller!.text,
        '7.25',
      );
      expect(
        tester.widget<TextField>(kawpowInputs.last).controller!.text,
        '120',
      );
      expect(
        requests,
        callsAfterStartup + 1,
      ); // every local filter and star is free
      // Saving a filtered list must also save edits to algorithms that are hidden.
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(savedHashes['Etchash']!.algorithm.hashrate, 12.5);
      expect(savedHashes['Etchash']!.algorithm.power, 200);
      expect(savedHashes['KawPow']!.algorithm.hashrate, 7.25);
      expect(savedHashes['KawPow']!.algorithm.power, 120);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NavigationDestination, 'Prices'));
      await tester.pumpAndSettle();
      expect(exchangeRequests, 1);
      expect(find.text(r'$0.0100'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Favorites · 1'), findsOneWidget);

      // All screens also fit a compact device, dark theme, Russian and larger text.
      tester.view.physicalSize = const Size(360, 800);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Dark'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      await tester
          .element(find.byType(NavigationBar))
          .setLocale(const Locale('ru'));
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(NavigationBar))).brightness,
        Brightness.dark,
      );
      for (var index = 0; index < 4; index++) {
        await tester.tap(find.byType(NavigationDestination).at(index));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      // The GPU picker remains usable with a keyboard on a compact Russian screen.
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('home_gpus'.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add_gpu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('select_gpu_model')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.showKeyboard(find.byKey(const ValueKey('gpu_model_search')));
      await tester.pumpAndSettle();
      expect(find.byType(GpuModelPicker), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
