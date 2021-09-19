import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/serializers.dart';

part 'UsedGpu.g.dart';

abstract class UsedGpu implements Built<UsedGpu, UsedGpuBuilder> {
  Gpu get gpuData;
  int get quantity;

  UsedGpu._();

  factory UsedGpu([void Function(UsedGpuBuilder)? updates]) = _$UsedGpu;

  static Serializer<UsedGpu> get serializer => _$usedGpuSerializer;

  Map<String, dynamic> toJson() => serializers.serializeWith(UsedGpu.serializer, this) as Map<String, dynamic>;

  static UsedGpu? fromJson(Map<String, dynamic> json) => serializers.deserializeWith(UsedGpu.serializer, json);
}
