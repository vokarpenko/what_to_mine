// ignore_for_file: prefer_initializing_formals

import '../../constants.dart';
import 'crypto_currency.dart';

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

  Earnings._({
    required double dayEarningInCrypto,
    required double dayEarningInCurrency,
    required double netDayEarningInCurrency,
    required double dayElectricityCost,
    required CryptoCurrency cryptoCurrency,
  }) : dayEarningInCrypto = dayEarningInCrypto,
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

  // WhatToMine calculates daily rewards and revenue after its default coin fee.
  // Electricity is already deducted from profit: do not subtract it again.
  factory Earnings.fromCalculation({
    required CryptoCurrency currency,
    required double dayEarningInCrypto,
    required double dayEarningInCurrency,
    required double netDayEarningInCurrency,
  }) => Earnings._(
    cryptoCurrency: currency,
    dayEarningInCrypto: dayEarningInCrypto,
    dayEarningInCurrency: dayEarningInCurrency,
    netDayEarningInCurrency: netDayEarningInCurrency,
    dayElectricityCost: dayEarningInCurrency - netDayEarningInCurrency,
  );

  bool monthEarningsMoreThan(double value) {
    return monthEarningInCurrency > value;
  }
}
