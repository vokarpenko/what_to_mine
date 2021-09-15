import 'dart:async';

import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/IMinerStatClient.dart';
import 'package:what_to_mine/src/data/db/entities/UsedGpuEntity.dart';
import 'package:what_to_mine/src/data/local/ILocalJsonReader.dart';
import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/logic/gateway/IGateway.dart';

import '../domain/algorithms/Algos.dart';
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
  Future<List<UsedGpu>?> getUsedGPUList() async {
    List<UsedGpu>? result = [];
    List<UsedGpuEntity> listEntity = (await this._appDatabase.usedGpuDao.selectAll());
    listEntity.forEach((element) {
      result.add(element.usedGpu);
    });
    print(result);
    return result;
  }

  // Добавить используемую в расчетах видеокарту
  @override
  Future<void> addUsedGpu(UsedGpu usedGpu) async {
    // Проверяем, если такая видеокарта уже есть, то суммируем их количество
    UsedGpuEntity? usedGpuEntity = await _appDatabase.usedGpuDao.selectById(usedGpu.gpu.id);
    if (usedGpuEntity != null) {
      int oldQuantity = usedGpuEntity.usedGpu.quantity;
      UsedGpu newUsedGpu = (UsedGpuBuilder()
            ..quantity = oldQuantity + usedGpu.quantity
            ..gpu = usedGpu.gpu.toBuilder())
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
  Future<Algos?> getUsedHashrates() async {
    double Cuckarood29 = 0;
    double Cuckatoo31 = 0;
    double Cuckatoo32 = 0;
    double CuckooCycle = 0;
    double CuckooCortex = 0;
    double Equihash = 0;
    double Equihash_125_4 = 0;
    double Equihash_144_5 = 0;
    double BeamHash = 0;
    double Ethash = 0;
    double Etchash = 0;
    double MTP = 0;
    double KAWPOW = 0;
    double RandomX = 0;
    double Eaglesong = 0;
    double Autolykos2 = 0;

    List<UsedGpu>? usedGpus = await getUsedGPUList();
    if (usedGpus == null) return null;
    usedGpus.forEach((gpu) {
      Algos algos = gpu.gpu.algos;
      int quantity = gpu.quantity;

      if (algos.Cuckarood29 != null) Cuckarood29 += algos.Cuckarood29! * quantity;
      if (algos.Cuckatoo31 != null) Cuckatoo31 += algos.Cuckatoo31! * quantity;
      if (algos.Cuckatoo32 != null) Cuckatoo32 += algos.Cuckatoo32! * quantity;
      if (algos.CuckooCycle != null) CuckooCycle += algos.CuckooCycle! * quantity;
      if (algos.CuckooCortex != null) CuckooCortex += algos.CuckooCortex! * quantity;
      if (algos.Equihash != null) Equihash += algos.Equihash! * quantity;
      if (algos.Equihash_125_4 != null) Equihash_125_4 += algos.Equihash_125_4! * quantity;
      if (algos.Equihash_144_5 != null) Equihash_144_5 += algos.Equihash_144_5! * quantity;
      if (algos.BeamHash != null) BeamHash += algos.BeamHash! * quantity;
      if (algos.Ethash != null) Ethash += algos.Ethash! * quantity;
      if (algos.Etchash != null) Etchash += algos.Etchash! * quantity;
      if (algos.MTP != null) MTP += algos.MTP! * quantity;
      if (algos.KAWPOW != null) KAWPOW += algos.KAWPOW! * quantity;
      if (algos.RandomX != null) RandomX += algos.RandomX! * quantity;
      if (algos.Eaglesong != null) Eaglesong += algos.Eaglesong! * quantity;
      if (algos.Autolykos2 != null) Autolykos2 += algos.Autolykos2! * quantity;
    });
    Algos result = (AlgosBuilder()
          ..Cuckarood29 = Cuckarood29
          ..Cuckatoo31 = Cuckatoo31
          ..Cuckatoo32 = Cuckatoo32
          ..CuckooCycle = CuckooCycle
          ..CuckooCortex = CuckooCortex
          ..Equihash = Equihash
          ..Equihash_125_4 = Equihash_125_4
          ..Equihash_144_5 = Equihash_144_5
          ..BeamHash = BeamHash
          ..Ethash = Ethash
          ..Etchash = Etchash
          ..MTP = MTP
          ..KAWPOW = KAWPOW
          ..RandomX = RandomX
          ..Eaglesong = Eaglesong
          ..Autolykos2 = Autolykos2)
        .build();
    return result;
  }

  // Получить доход по всем криптовалютам
  @override
  Future<List<Earnings>> getEarningsList() async {
    List<CryptoCurrency> currencies = await getCryptoCurrenciesList();
    Algos? usedHashrates = await getUsedHashrates();
    List<Earnings> result = [];
    if (usedHashrates == null) return result;

    currencies.forEach((currency) {
      switch (currency.algorithm.toLowerCase()) {
        case "ethash":
          if (usedHashrates.Ethash != null) {
            Earnings earnings = _buildEarning(currency, usedHashrates.Ethash!, HashPrefix.megaHash);
            print(currency.name + " " + earnings.dayEarningInCurrency.toString());
            result.add(earnings);
          }
          break;
        case "etchash":
          if (usedHashrates.Etchash != null) {
            Earnings earnings = _buildEarning(currency, usedHashrates.Etchash!, HashPrefix.megaHash);
            print(currency.name + " " + earnings.dayEarningInCurrency.toString());
            result.add(earnings);
          }
          break;
        case "kawpow":
          if (usedHashrates.KAWPOW != null) {
            Earnings earnings = _buildEarning(currency, usedHashrates.KAWPOW!, HashPrefix.megaHash);
            print(currency.name + " " + earnings.dayEarningInCurrency.toString());
            result.add(earnings);
          }
          break;
        case "autolykos2":
          if (usedHashrates.Autolykos2 != null) {
            Earnings earnings = _buildEarning(currency, usedHashrates.Autolykos2!, HashPrefix.megaHash);
            print(currency.name + " " + earnings.dayEarningInCurrency.toString());
            result.add(earnings);
          }
      }
    });
    return result;
  }

  // Создать экзепляр класса "Earnings"
  Earnings _buildEarning(CryptoCurrency currency, double hashrate, int hashratePrefix) {
    return Earnings(
      cryptoCurrency: currency,
      dayEarningInCurrency: currency.calculateEarning(hashrate * hashratePrefix, Hours.hoursInDay) * currency.price,
      dayEarningInCrypto: currency.calculateEarning(hashrate * hashratePrefix, Hours.hoursInDay),
      weekEarningInCurrency: currency.calculateEarning(hashrate * hashratePrefix, Hours.hoursInWeek) * currency.price,
      weekEarningInCrypto: currency.calculateEarning(hashrate * hashratePrefix, Hours.hoursInWeek),
      monthEarningInCurrency: currency.calculateEarning(hashrate * hashratePrefix, Hours.hoursInMonth) * currency.price,
      monthEarningInCrypto: currency.calculateEarning(hashrate * hashratePrefix, Hours.hoursInMonth),
    );
  }
}
