import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';

import '../../constants.dart';

class Earnings {
  final double dayEarningInCrypto;
  final double weekEarningInCrypto;
  final double monthEarningInCrypto;

  final double dayEarningInCurrency;
  final double weekEarningInCurrency;
  final double monthEarningInCurrency;

  final double netDayEarningInCurrency;
  final double netWeekEarningInCurrency;
  final double netMonthEarningInCurrency;

  final double dayElectricityCost;
  final double weekElectricityCost;
  final double monthElectricityCost;

  final CryptoCurrency cryptoCurrency;

  Earnings._(
      {required double dayEarningInCrypto,
      required double dayEarningInCurrency,
      required double netDayEarningInCurrency,
      required double dayElectricityCost,
      required CryptoCurrency cryptoCurrency})
      : dayEarningInCrypto = dayEarningInCrypto,
        weekEarningInCrypto = dayEarningInCrypto * daysInWeek,
        monthEarningInCrypto = dayEarningInCrypto * daysInMonth,
        dayEarningInCurrency = dayEarningInCurrency,
        weekEarningInCurrency = dayEarningInCurrency * daysInWeek,
        monthEarningInCurrency = dayEarningInCurrency * daysInMonth,
        netDayEarningInCurrency = netDayEarningInCurrency,
        netWeekEarningInCurrency = netDayEarningInCurrency * daysInWeek,
        netMonthEarningInCurrency = netDayEarningInCurrency * daysInMonth,
        dayElectricityCost = dayElectricityCost,
        weekElectricityCost = dayElectricityCost * daysInWeek,
        monthElectricityCost = dayElectricityCost * daysInMonth,
        cryptoCurrency = cryptoCurrency;

  static Earnings create(CryptoCurrency currency, HashAlgorithm algorithm, double electricityCost) {
    double dayEarningInCrypto = currency.calculateDayEarning((algorithm.hashrate ?? 0) * algorithm.hashrateCoefficient);
    double dayEarningInCurrency = dayEarningInCrypto * currency.price;
    double dayElectricityCost = (algorithm.power ?? 0) * electricityCost * hoursInDay / wattInKiloWatt;
    double netDayEarningInCurrency = dayEarningInCurrency - dayElectricityCost;
    return Earnings._(
        cryptoCurrency: currency,
        dayEarningInCurrency: dayEarningInCurrency,
        dayEarningInCrypto: dayEarningInCrypto,
        dayElectricityCost: dayElectricityCost,
        netDayEarningInCurrency: netDayEarningInCurrency);
  }

  bool monthEarningsMoreThan(double value) {
    return this.monthEarningInCurrency > value;
  }
}
