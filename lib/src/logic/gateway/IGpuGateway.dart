import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

abstract class IGpuGateway {
  // Получить список всех видеокарт
  Future<List<Gpu>?> getGPUList();

  // Получить список используемых в расчетах видеокарт
  Future<List<UsedGpu>?> getUsedGPUList();

  // Добавить используемую в расчетах видеокарту
  Future<void> addUsedGpu(UsedGpu usedGpu);

  // Удалить используемую в расчетах видеокарту
  Future<void> deleteUsedGpu(String id);

  //Подписка на изменения используемых видеокарт
  Stream<bool> usedGpuChangedStream();
}
