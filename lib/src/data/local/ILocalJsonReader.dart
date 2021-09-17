import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';

abstract class ILocalJsonReader {
  // Получить список видеокарт
  Future<List<Gpu>?> getGPUList();

  // Получить map коэффициентов единиц измерения хешрейтов
  Future<Map<String, dynamic>> getHashrateCoefficients();

  // Получить список алгоритмов без значений
  Future<List<HashAlgorithm>> getHashAlgorithmsWithZeroValues();
}
