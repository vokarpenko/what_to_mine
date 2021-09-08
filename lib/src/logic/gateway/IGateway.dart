import 'package:what_to_mine/src/domain/currency/Earnings.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

import '../../domain/algorithms/Algos.dart';
import '../../domain/currency/CryptoCurrency.dart';

abstract class IGateway {
  // Получить список криптовалют
  Future<List<CryptoCurrency>> getCryptoCurrenciesList();

  // Получить список видеокарт
  Future<List<Gpu>?> getGPUList();

  // Получить список используемых в расчетах видеокарт
  Future<List<UsedGpu>?> getUsedGPUList();

  // Добавить используемую в расчетах видеокарту
  Future<void> addUsedGpu(UsedGpu usedGpu);

  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  Future<Algos?> getUsedHashrates();

  // Получить доход по всем криптовалютам
  Future<List<Earnings>> getEarningsList();
}
