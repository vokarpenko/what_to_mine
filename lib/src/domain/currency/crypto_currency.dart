// ignore_for_file: prefer_typing_uninitialized_variables
import 'dart:math';

import 'package:easy_localization/easy_localization.dart' show NumberFormat;

import '../../constants.dart';

final _usdWithThousands = NumberFormat('#,##0.00', 'en_US');

class CryptoCurrency {
  final String id;
  final String coin;
  final String name;
  final String type;
  final String algorithm;
  final double price;
  final double? usdPrice;
  final String quoteCurrency;
  final double reward;
  final double networkHashrate;
  final String rewardUnit;
  final double volume;
  String? iconLink;

  CryptoCurrency({
    required this.id,
    required this.coin,
    required this.name,
    required this.type,
    required this.algorithm,
    required this.price,
    this.usdPrice,
    this.quoteCurrency = 'USD',
    required this.reward,
    required this.networkHashrate,
    required this.rewardUnit,
    required this.volume,
    this.iconLink,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    var reward;
    if (json['reward'] != null && json['reward'] > 0) {
      reward = json['reward'].toString();
      reward = double.tryParse(reward);
    } else {
      reward = 0.0;
    }

    var price;
    if (json['price'] != null && json['price'] > 0) {
      price = json['price'].toString();
      price = double.tryParse(price);
    } else {
      price = 0.0;
    }

    var networkHashrate;
    if (json['network_hashrate'] != null && json['network_hashrate'] > 0) {
      networkHashrate = json['network_hashrate'].toString();
      networkHashrate = double.tryParse(networkHashrate);
    } else {
      networkHashrate = 0.0;
    }

    var volume;
    if (json['volume'] != null && json['volume'] > 0) {
      volume = json['volume'].toString();
      volume = double.tryParse(volume);
    } else {
      volume = 0.0;
    }

    return CryptoCurrency(
      id: json['id'],
      coin: json['coin'],
      name: json['name'],
      type: json['type'],
      algorithm: json['algorithm'],
      price: price,
      reward: reward,
      networkHashrate: networkHashrate,
      rewardUnit: json['reward_unit'],
      volume: volume,
    );
  }

  String get formattedPrice =>
      price < 0 ? '—' : '${price.toStringAsPrecision(6)} $quoteCurrency';

  // Preserve source prices and BTC volumes; only the price tab uses this quote.
  CryptoCurrency withUsdPrice(double? value) => CryptoCurrency(
    id: id,
    coin: coin,
    name: name,
    type: type,
    algorithm: algorithm,
    price: price,
    quoteCurrency: quoteCurrency,
    usdPrice: value,
    reward: reward,
    networkHashrate: networkHashrate,
    rewardUnit: rewardUnit,
    volume: volume,
    iconLink: iconLink,
  );

  String get formattedUsdPrice {
    final value = usdPrice ?? (quoteCurrency == 'USD' ? price : null);
    if (value == null || !value.isFinite || value < 0) return '—';
    if (value == 0) return r'$0.00';
    if (value < 0.000000000001) return r'<$0.000000000001';
    if (value >= 1) return '\$${_usdWithThousands.format(value)}';
    final digits = (2 - (log(value) / ln10).floor()).clamp(2, 12).toInt();
    return '\$${value.toStringAsFixed(digits)}';
  }

  String get formattedVolume =>
      '${volume.toStringAsFixed(quoteCurrency == 'BTC' ? 8 : 2)} $quoteCurrency';

  String getStringNetworkHashrate() {
    if (networkHashrate == 0.0) return '';
    int intHashrate = networkHashrate.toInt();
    int length = intHashrate.toString().length;
    // Ph/s
    if (length >= 16 && length <= 18) {
      return ('${(intHashrate / pow(10, 15)).toStringAsFixed(2)} Ph/s');
    }
    // Th/s
    if (length >= 13 && length <= 15) {
      return ('${(intHashrate / pow(10, 12)).toStringAsFixed(2)} Th/s');
    }
    // Gh/s
    if (length >= 10 && length <= 12) {
      return ('${(intHashrate / pow(10, 9)).toStringAsFixed(2)} Gh/s');
    }
    // Mh/s
    if (length >= 7 && length <= 9) {
      return ('${(intHashrate / pow(10, 6)).toStringAsFixed(2)} Mh/s');
    }
    return '$intHashrate h/s';
  }

  double calculateDayEarning(double? usedHashrate) {
    if (reward > 0 && usedHashrate != null && usedHashrate > 0) {
      return reward * usedHashrate * hoursInDay;
    } else {
      return 0;
    }
  }

  bool isCoin() {
    return type == 'coin';
  }

  bool hasPrice() {
    return price != -1;
  }

  bool hasReward() {
    return reward != -1;
  }

  bool volumeMoreThan(double volume) {
    return this.volume > volume;
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(other) =>
      other is CryptoCurrency &&
      name == other.name &&
      coin == other.coin &&
      name == other.name &&
      type == other.type &&
      algorithm == other.algorithm &&
      price == other.price &&
      usdPrice == other.usdPrice &&
      quoteCurrency == other.quoteCurrency &&
      reward == other.reward &&
      networkHashrate == other.networkHashrate &&
      rewardUnit == other.rewardUnit &&
      volume == other.volume &&
      iconLink == other.iconLink;

  @override
  String toString() =>
      '\n{ \n id = $id \n coin = $coin \n name = $name \n type = $type \n algorithm = $algorithm \n price = $price \n reward = $reward \n networkHashrate = $networkHashrate \n rewardUnit = $rewardUnit \n volume = $volume \n iconLink = $iconLink \n}';
}
