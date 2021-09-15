import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'AlgorithmHashrate.g.dart';

abstract class AlgorithmHashrate implements Built<AlgorithmHashrate, AlgorithmHashrateBuilder> {
  Algorithm get name;
  double get value;
  bool get useDefault;

  AlgorithmHashrate._();

  factory AlgorithmHashrate([void Function(AlgorithmHashrateBuilder) updates]) = _$AlgorithmHashrate;

  static Serializer<AlgorithmHashrate> get serializer => _$algorithmHashrateSerializer;
}

class Algorithm extends EnumClass {
  static const Algorithm kawpow = _$kawpow; // kawpow
  static const Algorithm ethash = _$ethash; // ethash

  const Algorithm._(String name) : super(name);

  static BuiltSet<Algorithm> get values => _$algorithmValues;

  static Algorithm valueOf(String name) => _$algorithmValueOf(name);

  static Serializer<Algorithm> get serializer => _$algorithmSerializer;
}
