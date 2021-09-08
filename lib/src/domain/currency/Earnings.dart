import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';

class Earnings {
  final double dayEarningInCrypto;
  final double weekEarningInCrypto;
  final double monthEarningInCrypto;

  final double dayEarningInCurrency;
  final double weekEarningInCurrency;
  final double monthEarningInCurrency;

  final CryptoCurrency cryptoCurrency;

  Earnings(
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
}
