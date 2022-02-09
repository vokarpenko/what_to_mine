import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';
import 'package:what_to_mine/src/serializers.dart';

part 'gpu.g.dart';

abstract class Gpu implements Built<Gpu, GpuBuilder> {
  String get id;
  String get name;
  String get marketingName;
  String get vendor;
  int get price;
  bool get secondHand;
  @BuiltValueField(wireName: 'algos')
  BuiltList<HashAlgorithm> get hashAlgorithms;

  Gpu._();

  factory Gpu([void Function(GpuBuilder) updates]) = _$Gpu;

  static Serializer<Gpu> get serializer => _$gpuSerializer;

  Map<String, dynamic> toJson() => serializers.serializeWith(Gpu.serializer, this) as Map<String, dynamic>;

  static Gpu? fromJson(Map<String, dynamic> json) => serializers.deserializeWith(Gpu.serializer, json);
}
