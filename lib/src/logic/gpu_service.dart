import 'package:what_to_mine/src/domain/gpu/gpu.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';

import 'gateway/gpu_gateway.dart';

class GpuService {
  final IGpuGateway _gateway;

  GpuService({required IGpuGateway gateway}) : _gateway = gateway;

  // Получить список всех видеокарт
  Future<List<Gpu>?> getGPUList() async {
    return _gateway.getGPUList();
  }

  // Получить список используемых в расчетах видеокарт
  Future<List<UsedGpu>?> getUsedGPUList() async {
    return _gateway.getUsedGPUList();
  }

  // Добавить используемую в расчетах видеокарту
  Future<void> addUsedGpu(UsedGpu usedGpu) async {
    return _gateway.addUsedGpu(usedGpu);
  }

  // Удалить используемую в расчетах видеокарту
  Future<void> deleteUsedGpu(String id) async {
    return _gateway.deleteUsedGpu(id);
  }

  //Подписка на изменения используемых видеокарт
  Stream<bool> onUsedGpuChanged() {
    return _gateway.usedGpuChangedStream();
  }
}
