import 'package:floor/floor.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';

@Entity(tableName: 'used_gpu')
class UsedGpuEntity {
  @primaryKey
  final String id;

  final UsedGpu usedGpu;

  UsedGpuEntity(this.usedGpu) : id = usedGpu.gpuData.id;
}
