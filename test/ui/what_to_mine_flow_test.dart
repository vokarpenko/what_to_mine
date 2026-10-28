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
import 'package:what_to_mine/src/data/db/entities/used_gpu_entity.dart';
import 'package:what_to_mine/src/domain/settings.dart';

import '../fixtures/what_to_mine_fixtures.dart';
import '../mocks.mocks.dart';
import '../test_objects_factory.dart';
import 'package:what_to_mine/src/ui/screens/gpu/gpu_list_screen.dart';
import 'package:what_to_mine/src/ui/screens/hashrate/hashrate_screen.dart';

void main() {
  testWidgets(
    'saved rig opens earnings, BTC prices, current GPU catalog, and hashrates',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        's': Settings(isFirstRun: false).toJsonString(),
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
            'calculate' => wtmCalculation,
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
      await initializeApp(client: api, appDatabase: database);

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ru')],
          path: 'assets/translations',
          startLocale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          child: const App(),
        ),
      );
      // Asset loading uses real I/O; the splash also has an intentional 1s delay.
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('-0.0900 USD'), findsOneWidget);
      expect(find.text('-2.7000 USD'), findsOneWidget);
      expect(tester.takeException(), isNull);

      expect(requests, 2); // coins + calculate; no eager catalogs
      expect(find.byType(GpuListScreen), findsNothing);
      expect(find.byType(HashrateScreen), findsNothing);
      final callsAfterStartup = requests;
      await tester.tap(find.text('Prices'));
      await tester.pumpAndSettle();
      expect(find.text('Cryptocurrency prices (BTC)'), findsOneWidget);
      expect(find.textContaining('BTC'), findsWidgets);
      expect(find.text('Ravencoin'), findsOneWidget);
      expect(requests, callsAfterStartup);

      await tester.tap(find.text('GPUs'));
      await tester.pumpAndSettle();
      expect(find.text('nvidea gtx 1080'), findsOneWidget);
      expect(requests, callsAfterStartup);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('Adding GPUs'), findsOneWidget);
      expect(find.text('AMD'), findsOneWidget);
      expect(find.text('OTHER'), findsNothing);
      expect(requests, callsAfterStartup + 1);
      await tester.tap(find.text('AMD'));
      await tester.pumpAndSettle();
      expect(find.text('NVIDIA'), findsOneWidget);
      await tester.tap(find.text('NVIDIA'));
      await tester.pumpAndSettle();
      expect(find.text('GeForce RTX 4090'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hashrates'));
      await tester.pumpAndSettle();
      expect(find.text('KawPow'), findsWidgets);
      expect(requests, callsAfterStartup + 1);
      expect(tester.takeException(), isNull);
    },
  );
}
