import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'HashAlgorithm.g.dart';

abstract class HashAlgorithm implements Built<HashAlgorithm, HashAlgorithmBuilder> {
  @BuiltValueField(wireName: 'name')
  String get name;

  @BuiltValueField(wireName: 'value')
  double? get hashrate;

  @BuiltValueField(wireName: 'coefficient')
  int get hashrateCoefficient;

  HashAlgorithm._();

  factory HashAlgorithm([void Function(HashAlgorithmBuilder) updates]) = _$HashAlgorithm;

  static Serializer<HashAlgorithm> get serializer => _$hashAlgorithmSerializer;
}
