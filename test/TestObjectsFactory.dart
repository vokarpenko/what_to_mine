import 'package:built_collection/src/list.dart';
import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/data/db/entities/UsedGpuEntity.dart';
import 'package:what_to_mine/src/data/db/entities/UserHashAlgorithmEntity.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/CryptoCurrency.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

class TestObjectsFactory {
  //  Запрещаем создавать экземпляры
  TestObjectsFactory._();

  static CryptoCurrency createEth() {
    return CryptoCurrency(
        name: 'eth',
        volume: 10000000,
        reward: 5,
        algorithm: 'ethash',
        coin: 'eth',
        id: 'eth',
        networkHashrate: 1000,
        price: 3000,
        rewardUnit: 'eth',
        type: 'coin',
        iconLink: '');
  }

  static CryptoCurrency createEtc() {
    return CryptoCurrency(
        name: 'etc',
        volume: 500000,
        reward: 3,
        algorithm: 'etchash',
        coin: 'etc',
        id: 'etc',
        networkHashrate: 50,
        price: 40,
        rewardUnit: 'etc',
        type: 'coin',
        iconLink: '');
  }

  static CryptoCurrency createRvn() {
    return CryptoCurrency(
        name: 'rvn',
        volume: 600000,
        reward: 2,
        algorithm: 'kawpow',
        coin: 'rvn',
        id: 'rvn',
        networkHashrate: 50,
        price: 0.1,
        rewardUnit: 'rvn',
        type: 'coin',
        iconLink: '');
  }

  static CryptoCurrency createCurrencyWithoutReward() {
    return CryptoCurrency(
        name: 'bad',
        volume: 500000,
        reward: -1,
        algorithm: 'bad',
        coin: 'bad',
        id: 'bad',
        networkHashrate: 50,
        price: 0.1,
        rewardUnit: 'bad',
        type: 'coin',
        iconLink: '');
  }

  static CryptoCurrency createCurrencyWithoutPrice() {
    return CryptoCurrency(
        name: 'bad',
        volume: 500000,
        reward: 100,
        algorithm: 'bad',
        coin: 'bad',
        id: 'bad',
        networkHashrate: 50,
        price: -1,
        rewardUnit: 'bad',
        type: 'coin',
        iconLink: '');
  }

  static CryptoCurrency createCurrencyWithSmallVolume() {
    return CryptoCurrency(
        name: 'bad',
        volume: 100,
        reward: 4,
        algorithm: 'bad',
        coin: 'bad',
        id: 'bad',
        networkHashrate: 50,
        price: 2,
        rewardUnit: 'bad',
        type: 'coin',
        iconLink: '');
  }

  static List<CryptoCurrency> createCryptoCurrenciesList() {
    List<CryptoCurrency> result = [];
    result.add(createEth());
    result.add(createCurrencyWithSmallVolume());
    result.add(createEtc());
    result.add(createCurrencyWithoutPrice());
    result.add(createRvn());
    result.add(createCurrencyWithoutReward());
    return result;
  }

  static List<CryptoCurrency> createCryptoCurrenciesListWithFilters() {
    List<CryptoCurrency> result = [];
    var eth = createEth();
    var etc = createEtc();
    var rvn = createRvn();

    eth.iconLink = Links.iconsLink + eth.coin.toLowerCase() + '.png';
    etc.iconLink = Links.iconsLink + etc.coin.toLowerCase() + '.png';
    rvn.iconLink = Links.iconsLink + rvn.coin.toLowerCase() + '.png';

    result.add(eth);
    result.add(etc);
    result.add(rvn);
    return result;
  }

  static Gpu createGtx1080() => Gpu((g) => g
    ..name = 'gtx1080'
    ..hashAlgorithms = (ListBuilder<HashAlgorithm>([createEthash(10, 100), createKawpow(10, 100)]))
    ..secondHand = false
    ..price = 100
    ..id = 'gtx1080'
    ..vendor = 'nvidea'
    ..marketingName = 'nvidea gtx 1080');

  static Gpu createGtx1070() => Gpu((g) => g
    ..name = 'gtx1070'
    ..hashAlgorithms = (ListBuilder<HashAlgorithm>([createEthash(10, 100), createKawpow(10, 100)]))
    ..secondHand = false
    ..price = 100
    ..id = 'gtx1070'
    ..vendor = 'nvidea'
    ..marketingName = 'nvidea gtx 1070');

  static Gpu createGtx570() => Gpu((g) => g
    ..name = 'rx570'
    ..secondHand = false
    ..price = 100
    ..id = 'rx570'
    ..vendor = 'amd'
    ..marketingName = 'amd rx 570');

  static UsedGpu createUsedGpuGtx1080(int quantity) => UsedGpu((g) => g
    ..quantity = quantity
    ..gpuData = createGtx1080().toBuilder());

  static UsedGpu createUsedGpuGtx1070(int quantity) => UsedGpu((g) => g
    ..quantity = quantity
    ..gpuData = createGtx1070().toBuilder());

  static UsedGpu createUsedGpuRx570(int quantity) => UsedGpu((g) => g
    ..quantity = quantity
    ..gpuData = createGtx570().toBuilder());

  static UsedGpuEntity createUsedGpuEntityRx570(int quantity) => UsedGpuEntity(createUsedGpuRx570(quantity));

  static UsedGpuEntity createUsedGpuEntityGtx1070(int quantity) => UsedGpuEntity(createUsedGpuGtx1070(quantity));

  static UsedGpuEntity createUsedGpuEntityGtx1080(int quantity) => UsedGpuEntity(createUsedGpuGtx1080(quantity));

  static List<UsedGpu> createUsedGpus() => [createUsedGpuGtx1070(2), createUsedGpuGtx1080(1)];

  static List<UsedGpuEntity> createUsedGpusEntities() => [createUsedGpuEntityGtx1070(2), createUsedGpuEntityGtx1080(1)];

  static HashAlgorithm createEthash(double hashrate, int power) => HashAlgorithm((a) => a
    ..name = 'ethash'
    ..hashrate = hashrate
    ..power = power
    ..hashrateCoefficient = HashCoefficient.megaHash);

  static HashAlgorithm createKawpow(double hashrate, int power) => HashAlgorithm((a) => a
    ..name = 'kawpow'
    ..hashrate = hashrate
    ..power = power
    ..hashrateCoefficient = HashCoefficient.megaHash);

  static List<HashAlgorithm> createHashAlgorithms() => [createEthash(30, 300), createKawpow(30, 300)];

  static List<UserHashAlgorithmEntity> createEntitiesHashAlgorithms() =>
      [UserHashAlgorithmEntity(createEthash(30, 300)), UserHashAlgorithmEntity(createKawpow(30, 300))];

  static List<HashAlgorithm> createHashAlgorithmsWithZeroValues() => [createEthash(0, 0), createKawpow(0, 0)];
}
