import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';

import '../../constants.dart';

class Earnings {
  final double dayEarningInCrypto;
  final double weekEarningInCrypto;
  final double monthEarningInCrypto;

  final double dayEarningInCurrency;
  final double weekEarningInCurrency;
  final double monthEarningInCurrency;

  final CryptoCurrency cryptoCurrency;

  Earnings._(
      {required double dayEarningInCrypto,
      required double weekEarningInCrypto,
      required double monthEarningInCrypto,
      required double dayEarningInCurrency,
      required double weekEarningInCurrency,
      required double monthEarningInCurrency,
      required CryptoCurrency cryptoCurrency})
      : dayEarningInCrypto = dayEarningInCrypto,
        weekEarningInCrypto = weekEarningInCrypto,
        monthEarningInCrypto = monthEarningInCrypto,
        dayEarningInCurrency = dayEarningInCurrency,
        weekEarningInCurrency = weekEarningInCurrency,
        monthEarningInCurrency = monthEarningInCurrency,
        cryptoCurrency = cryptoCurrency;

  static Earnings calc(CryptoCurrency currency, double hashrate, int hashrateCoefficient) {
    return Earnings._(
      cryptoCurrency: currency,
      dayEarningInCurrency:
          currency.calculateEarning(hashrate * hashrateCoefficient, Hours.hoursInDay) * currency.price,
      dayEarningInCrypto: currency.calculateEarning(hashrate * hashrateCoefficient, Hours.hoursInDay),
      weekEarningInCurrency:
          currency.calculateEarning(hashrate * hashrateCoefficient, Hours.hoursInWeek) * currency.price,
      weekEarningInCrypto: currency.calculateEarning(hashrate * hashrateCoefficient, Hours.hoursInWeek),
      monthEarningInCurrency:
          currency.calculateEarning(hashrate * hashrateCoefficient, Hours.hoursInMonth) * currency.price,
      monthEarningInCrypto: currency.calculateEarning(hashrate * hashrateCoefficient, Hours.hoursInMonth),
    );
  }
}
