import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:what_to_mine/src/constants.dart';
import 'package:what_to_mine/src/serializers.dart';

part 'HashAlgorithm.g.dart';

abstract class HashAlgorithm implements Built<HashAlgorithm, HashAlgorithmBuilder> {
  @BuiltValueField(wireName: 'name')
  String get name;

  @BuiltValueField(wireName: 'value')
  double? get hashrate;

  @BuiltValueField(wireName: 'coefficient')
  int get hashrateCoefficient;

  @BuiltValueField(wireName: 'power')
  int? get power;

  HashAlgorithm._();

  factory HashAlgorithm([void Function(HashAlgorithmBuilder) updates]) = _$HashAlgorithm;

  static Serializer<HashAlgorithm> get serializer => _$hashAlgorithmSerializer;

  Map<String, dynamic> toJson() => serializers.serializeWith(HashAlgorithm.serializer, this) as Map<String, dynamic>;

  static HashAlgorithm? fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith(HashAlgorithm.serializer, json);

  String getHashUnit() {
    switch (hashrateCoefficient) {
      case HashCoefficient.hash:
        return 'h/s';
      case HashCoefficient.kiloHash:
        return 'Kh/s';
      case HashCoefficient.megaHash:
        return 'Mh/s';
      case HashCoefficient.gigaHash:
        return 'Gh/s';
      default:
        return '';
    }
  }
}
