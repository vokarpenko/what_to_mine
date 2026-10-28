import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:what_to_mine/src/domain/currency/earnings.dart';
import 'package:what_to_mine/src/logic/currencies_service.dart';

import '../mocks.mocks.dart';
import '../test_objects_factory.dart';

void main() {
  Earnings earning(double profit) => Earnings.fromCalculation(
    currency: TestObjectsFactory.createCryptoCurrenciesList().first,
    dayEarningInCrypto: 1,
    dayEarningInCurrency: 1,
    netDayEarningInCurrency: profit,
  );

  test(
    'does not report loss-making coins as profitable in notifications',
    () async {
      final gateway = MockGateway();
      when(
        gateway.getEarningsList(isNeedFresh: false),
      ).thenAnswer((_) async => [earning(-0.1), earning(0)]);
      expect(
        await CurrenciesService(gateway: gateway).getMostProfitableCurrency(),
        isNull,
      );
    },
  );

  test(
    'chooses the highest net profit and reuses the normal API cache',
    () async {
      final gateway = MockGateway();
      when(
        gateway.getEarningsList(isNeedFresh: false),
      ).thenAnswer((_) async => [earning(0.1), earning(0.5)]);
      expect(
        (await CurrenciesService(
          gateway: gateway,
        ).getMostProfitableCurrency())?.netDayEarningInCurrency,
        0.5,
      );
    },
  );
}
