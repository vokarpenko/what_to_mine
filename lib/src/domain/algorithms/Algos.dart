import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'Algos.g.dart';

abstract class Algos implements Built<Algos, AlgosBuilder> {
  double? get Cuckarood29;
  double? get Cuckatoo31;
  double? get Cuckatoo32;
  double? get CuckooCycle;
  double? get CuckooCortex;
  double? get Equihash;
  double? get Equihash_125_4;
  double? get Equihash_144_5;
  double? get BeamHash;
  double? get Ethash;
  double? get Etchash;
  double? get MTP;
  double? get KAWPOW;
  double? get RandomX;
  double? get Eaglesong;
  double? get Autolykos2;

  Algos._();

  factory Algos([void Function(AlgosBuilder) updates]) = _$Algos;

  static Serializer<Algos> get serializer => _$algosSerializer;
}
