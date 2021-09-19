import 'dart:async';

import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/IMinerStatClient.dart';
import 'package:what_to_mine/src/data/db/entities/UsedGpuEntity.dart';
import 'package:what_to_mine/src/data/local/ILocalJsonReader.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/logic/gateway/IGateway.dart';

import '../domain/currency/CryptoCurrency.dart';
import 'db/AppDatabase.dart';

class Gateway implements IGateway {
  final IMinerStatClient _client;
  final ILocalJsonReader _jsonReader;
  final MemoryStorage _cache;
  final AppDatabase _appDatabase;
  Gateway(
      {required IMinerStatClient client,
      required ILocalJsonReader jsonReader,
      required MemoryStorage cache,
      required database})
      : _client = client,
        _jsonReader = jsonReader,
        _cache = cache,
        _appDatabase = database;

  final StreamController<bool> _onUsedGpuChanged = StreamController<bool>.broadcast();

  @override
  Stream<bool> onUsedGpuChanged() => _onUsedGpuChanged.stream;

  // Получить список криптовалют
  @override
  Future<List<CryptoCurrency>> getCryptoCurrenciesList() async {
    List<CryptoCurrency> list;

    List<CryptoCurrency>? listInCache = _cache.getCryptoCurrency();

    if (listInCache != null && listInCache.isNotEmpty) {
      list = listInCache;
    } else {
      list = await _client.getCryptoCurrenciesList();
      list = list
          .where((element) =>
              element.type == "coin" && element.price != -1 && element.reward != -1 && element.volume > 1000)
          .toList();
      list.forEach((element) {
        element.iconLink = Links.iconsLink + element.coin.toLowerCase() + ".png";
      });
      _cache.putCryptoCurrency(list);
    }
    return list;
  }

  // Получить список видеокарт
  @override
  Future<List<Gpu>?> getGPUList() async {
    return _jsonReader.getGPUList();
  }

  // Получить список используемых в расчетах видеокарт
  @override
  Future<List<UsedGpu>> getGpusUsedInCalc() async {
    List<UsedGpu> result = [];
    List<UsedGpuEntity> listEntity = (await this._appDatabase.usedGpuDao.selectAll());
    listEntity.forEach((element) {
      result.add(element.usedGpu);
    });
    return result;
  }

  // Добавить используемую в расчетах видеокарту
  @override
  Future<void> addUsedGpu(UsedGpu usedGpu) async {
    // Проверяем, если такая видеокарта уже есть, то суммируем их количество
    UsedGpuEntity? usedGpuEntity = await _appDatabase.usedGpuDao.selectById(usedGpu.gpuData.id);
    if (usedGpuEntity != null) {
      int oldQuantity = usedGpuEntity.usedGpu.quantity;
      UsedGpu newUsedGpu = (UsedGpuBuilder()
            ..quantity = oldQuantity + usedGpu.quantity
            ..gpuData = usedGpu.gpuData.toBuilder())
          .build();
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(newUsedGpu));
      _onUsedGpuChanged.add(true);
    } else {
      await _appDatabase.usedGpuDao.insert(UsedGpuEntity(usedGpu));
      _onUsedGpuChanged.add(true);
    }
  }

  // Удалить используемую в расчетах видеокарту
  @override
  Future<void> deleteUsedGpu(String id) async {
    await _appDatabase.usedGpuDao.deleteById(id);
    _onUsedGpuChanged.add(true);
  }

  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  @override
  Future<List<HashAlgorithm>> getHashratesUsedInCalc() async {
    print("***getHashratesUsedInCalc***");
    List<HashAlgorithm> result = await _jsonReader.getHashAlgorithmsWithZeroValues();
    List<UsedGpu> usedGpus = await getGpusUsedInCalc();

    //Map<String, double> totalHashrateMap = Map();
    usedGpus.forEach((gpu) {
      print(gpu.gpuData.name + " x" + gpu.quantity.toString());
      gpu.gpuData.hashAlgorithms.forEach((element) {
        if (element.hashrate != null) {
          int currentAlgorithmIndex = result.indexWhere((r) => r.name == element.name);
          double currentAlgorithmHashrate = result[currentAlgorithmIndex].hashrate!;
          /*
          print(element.name);
          print("b.hashrate! = " + result[currentAlgorithmIndex].hashrate!.toString());
          print("element.hashrate! * gpu.quantity = " + (element.hashrate! * gpu.quantity).toString());
          */

          result[currentAlgorithmIndex] =
              element.rebuild((b) => b..hashrate = (currentAlgorithmHashrate + (element.hashrate! * gpu.quantity)));
          /*if (totalHashrateMap.containsKey(element.name))
            totalHashrateMap.update(element.name, (value) => value + element.hashrate! * gpu.quantity);
          else
            totalHashrateMap.putIfAbsent(element.name, () => element.hashrate! * gpu.quantity);*/
        }
      });
    });
    /* totalHashrateMap.forEach((key, value) {
      result.add((HashAlgorithmBuilder()
            ..hashrate = value
            ..name = key
            ..hashrateCoefficient = 1)
          .build());
    });*/
    return result;
  }

  // Получить доход по всем криптовалютам
  @override
  Future<List<Earnings>> getEarningsList() async {
    List<CryptoCurrency> currencies = await getCryptoCurrenciesList();
    List<HashAlgorithm> hashratesUsedInCalc = await getHashratesUsedInCalc();
    List<Earnings> result = [];

    currencies.forEach((currency) {
      HashAlgorithm algorithm =
          hashratesUsedInCalc.singleWhere((element) => element.name.toLowerCase() == currency.algorithm.toLowerCase());
      Earnings earning = Earnings.calc(currency, algorithm.hashrate!, algorithm.hashrateCoefficient);
      result.add(earning);
    });
    // Фильтруем список, отбрасывая монеты, которые дают доход 0
    result = result.where((element) => element.monthEarningInCrypto > 0).toList();
    return result;
  }
}
