import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';

abstract class IJsonReader {
  // Получить список видеокарт
  Future<List<Gpu>?> getGPUList();

  // Получить список алгоритмов без значений
  Future<List<HashAlgorithm>> getHashAlgorithmsWithZeroValues();
}
