import 'package:what_to_mine/src/domain/gpu/Gpu.dart';

abstract class ILocalJsonReader {
  // Получить список видеокарт
  Future<List<Gpu>?> getGPUList();
}
