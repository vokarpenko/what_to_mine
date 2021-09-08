class CryptoCurrency {
  final String id;
  final String coin;
  final String name;
  final String type;
  final String algorithm;
  final double price;
  final double reward;
  final double networkHashrate;
  final String rewardUnit;
  final double volume;
  String? iconLink;

  /*
  final int difficulty;
  final String rewardBlock;
  final String updated;
  */

  CryptoCurrency(
      {required this.id,
      required this.coin,
      required this.name,
      required this.type,
      required this.algorithm,
      required this.price,
      required this.reward,
      required this.networkHashrate,
      required this.rewardUnit,
      required this.volume,
      this.iconLink

      /*
      required this.difficulty,
      required this.rewardBlock,
      required this.updated
      */
      });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    var reward;
    if (json['reward'] != null && json['reward'] > 0) {
      reward = json['reward'].toString();
      reward = double.tryParse(reward);
    } else
      reward = 0.0;

    var price;
    if (json['price'] != null && json['price'] > 0) {
      price = json['price'].toString();
      price = double.tryParse(price);
    } else
      price = 0.0;

    var networkHashrate;
    if (json['network_hashrate'] != null && json['network_hashrate'] > 0) {
      networkHashrate = json['network_hashrate'].toString();
      networkHashrate = double.tryParse(networkHashrate);
    } else
      networkHashrate = 0.0;

    var volume;
    if (json['volume'] != null && json['volume'] > 0) {
      volume = json['volume'].toString();
      volume = double.tryParse(volume);
    } else
      volume = 0.0;

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
        volume: volume
        /*
        rewardUnit: json['reward_unit'],
        rewardBlock: json['reward_block'],
        updated: json['updated'],
        */
        );
  }

  double calculateEarning(double? usedHashrate, int timeInHours) {
    if (reward > 0 && usedHashrate != null && usedHashrate > 0)
      return reward * usedHashrate * timeInHours;
    else
      return 0;
  }
}
