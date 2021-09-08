import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

import '../domain/algorithms/Algos.dart';
import 'gateway/IGateway.dart';

class GpuService {
  final IGateway _gateway;

  GpuService({required IGateway gateway}) : _gateway = gateway;

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

  // Получить список суммарных хэшрейтов используемых в расчетах видеокарт
  Future<Algos?> getUsedHashrates() async {
    return _gateway.getUsedHashrates();
  }
}
