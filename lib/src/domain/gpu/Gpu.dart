import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:what_to_mine/src/domain/algorithms/HashAlgorithm.dart';
import 'package:what_to_mine/src/serializers.dart';

part 'Gpu.g.dart';

abstract class Gpu implements Built<Gpu, GpuBuilder> {
  String get id;
  String get name;
  String get marketingName;
  String get vendor;
  //List<int> get  ramSize;
  int get price;
  bool get secondHand;
  @BuiltValueField(wireName: 'algos')
  BuiltList<HashAlgorithm> get hashAlgorithms;

  Gpu._();

  factory Gpu([void Function(GpuBuilder) updates]) = _$Gpu;

  static Serializer<Gpu> get serializer => _$gpuSerializer;

  Map<String, dynamic> toJson() => serializers.serializeWith(Gpu.serializer, this) as Map<String, dynamic>;

  static Gpu? fromJson(Map<String, dynamic> json) => serializers.deserializeWith(Gpu.serializer, json);

/*  GPU({
    required this.id,
    required this.name,
    required this.marketingName,
    required this.vendor,
    //required this.ramSize,
    required this.price,
    required this.secondHand,
    //required this.hashrate
  });*/

/*  factory GPU.fromJson(Map<String, dynamic> json) {
    return GPU(
      id: json['id'],
      name: json['name'],
      marketingName: json['marketing_name'],
      vendor: json['vendor'],
      price: json['price'],
      secondHand: json['secondHand'],
    );
  }*/
}
