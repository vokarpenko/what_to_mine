import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';

abstract class DataReader {
  // Получить список видеокарт
  Future<List<Gpu>?> getGPUList();

  // Получить список алгоритмов без значений
  Future<List<HashAlgorithm>> getHashAlgorithmsWithZeroValues();
}
