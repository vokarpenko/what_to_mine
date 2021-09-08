// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Algos.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Algos> _$algosSerializer = new _$AlgosSerializer();

class _$AlgosSerializer implements StructuredSerializer<Algos> {
  @override
  final Iterable<Type> types = const [Algos, _$Algos];
  @override
  final String wireName = 'Algos';

  @override
  Iterable<Object?> serialize(Serializers serializers, Algos object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.Cuckarood29;
    if (value != null) {
      result
        ..add('Cuckarood29')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Cuckatoo31;
    if (value != null) {
      result
        ..add('Cuckatoo31')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Cuckatoo32;
    if (value != null) {
      result
        ..add('Cuckatoo32')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.CuckooCycle;
    if (value != null) {
      result
        ..add('CuckooCycle')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.CuckooCortex;
    if (value != null) {
      result
        ..add('CuckooCortex')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Equihash;
    if (value != null) {
      result
        ..add('Equihash')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Equihash_125_4;
    if (value != null) {
      result
        ..add('Equihash_125_4')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Equihash_144_5;
    if (value != null) {
      result
        ..add('Equihash_144_5')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.BeamHash;
    if (value != null) {
      result
        ..add('BeamHash')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Ethash;
    if (value != null) {
      result
        ..add('Ethash')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Etchash;
    if (value != null) {
      result
        ..add('Etchash')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.MTP;
    if (value != null) {
      result
        ..add('MTP')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.KAWPOW;
    if (value != null) {
      result
        ..add('KAWPOW')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.RandomX;
    if (value != null) {
      result
        ..add('RandomX')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Eaglesong;
    if (value != null) {
      result
        ..add('Eaglesong')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.Autolykos2;
    if (value != null) {
      result
        ..add('Autolykos2')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    return result;
  }

  @override
  Algos deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new AlgosBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'Cuckarood29':
          result.Cuckarood29 = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Cuckatoo31':
          result.Cuckatoo31 = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Cuckatoo32':
          result.Cuckatoo32 = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'CuckooCycle':
          result.CuckooCycle = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'CuckooCortex':
          result.CuckooCortex = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Equihash':
          result.Equihash = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Equihash_125_4':
          result.Equihash_125_4 = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Equihash_144_5':
          result.Equihash_144_5 = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'BeamHash':
          result.BeamHash = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Ethash':
          result.Ethash = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Etchash':
          result.Etchash = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'MTP':
          result.MTP = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'KAWPOW':
          result.KAWPOW = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'RandomX':
          result.RandomX = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Eaglesong':
          result.Eaglesong = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'Autolykos2':
          result.Autolykos2 = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
      }
    }

    return result.build();
  }
}

class _$Algos extends Algos {
  @override
  final double? Cuckarood29;
  @override
  final double? Cuckatoo31;
  @override
  final double? Cuckatoo32;
  @override
  final double? CuckooCycle;
  @override
  final double? CuckooCortex;
  @override
  final double? Equihash;
  @override
  final double? Equihash_125_4;
  @override
  final double? Equihash_144_5;
  @override
  final double? BeamHash;
  @override
  final double? Ethash;
  @override
  final double? Etchash;
  @override
  final double? MTP;
  @override
  final double? KAWPOW;
  @override
  final double? RandomX;
  @override
  final double? Eaglesong;
  @override
  final double? Autolykos2;

  factory _$Algos([void Function(AlgosBuilder)? updates]) =>
      (new AlgosBuilder()..update(updates)).build();

  _$Algos._(
      {this.Cuckarood29,
      this.Cuckatoo31,
      this.Cuckatoo32,
      this.CuckooCycle,
      this.CuckooCortex,
      this.Equihash,
      this.Equihash_125_4,
      this.Equihash_144_5,
      this.BeamHash,
      this.Ethash,
      this.Etchash,
      this.MTP,
      this.KAWPOW,
      this.RandomX,
      this.Eaglesong,
      this.Autolykos2})
      : super._();

  @override
  Algos rebuild(void Function(AlgosBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AlgosBuilder toBuilder() => new AlgosBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Algos &&
        Cuckarood29 == other.Cuckarood29 &&
        Cuckatoo31 == other.Cuckatoo31 &&
        Cuckatoo32 == other.Cuckatoo32 &&
        CuckooCycle == other.CuckooCycle &&
        CuckooCortex == other.CuckooCortex &&
        Equihash == other.Equihash &&
        Equihash_125_4 == other.Equihash_125_4 &&
        Equihash_144_5 == other.Equihash_144_5 &&
        BeamHash == other.BeamHash &&
        Ethash == other.Ethash &&
        Etchash == other.Etchash &&
        MTP == other.MTP &&
        KAWPOW == other.KAWPOW &&
        RandomX == other.RandomX &&
        Eaglesong == other.Eaglesong &&
        Autolykos2 == other.Autolykos2;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    0,
                                                                    Cuckarood29
                                                                        .hashCode),
                                                                Cuckatoo31
                                                                    .hashCode),
                                                            Cuckatoo32
                                                                .hashCode),
                                                        CuckooCycle.hashCode),
                                                    CuckooCortex.hashCode),
                                                Equihash.hashCode),
                                            Equihash_125_4.hashCode),
                                        Equihash_144_5.hashCode),
                                    BeamHash.hashCode),
                                Ethash.hashCode),
                            Etchash.hashCode),
                        MTP.hashCode),
                    KAWPOW.hashCode),
                RandomX.hashCode),
            Eaglesong.hashCode),
        Autolykos2.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Algos')
          ..add('Cuckarood29', Cuckarood29)
          ..add('Cuckatoo31', Cuckatoo31)
          ..add('Cuckatoo32', Cuckatoo32)
          ..add('CuckooCycle', CuckooCycle)
          ..add('CuckooCortex', CuckooCortex)
          ..add('Equihash', Equihash)
          ..add('Equihash_125_4', Equihash_125_4)
          ..add('Equihash_144_5', Equihash_144_5)
          ..add('BeamHash', BeamHash)
          ..add('Ethash', Ethash)
          ..add('Etchash', Etchash)
          ..add('MTP', MTP)
          ..add('KAWPOW', KAWPOW)
          ..add('RandomX', RandomX)
          ..add('Eaglesong', Eaglesong)
          ..add('Autolykos2', Autolykos2))
        .toString();
  }
}

class AlgosBuilder implements Builder<Algos, AlgosBuilder> {
  _$Algos? _$v;

  double? _Cuckarood29;
  double? get Cuckarood29 => _$this._Cuckarood29;
  set Cuckarood29(double? Cuckarood29) => _$this._Cuckarood29 = Cuckarood29;

  double? _Cuckatoo31;
  double? get Cuckatoo31 => _$this._Cuckatoo31;
  set Cuckatoo31(double? Cuckatoo31) => _$this._Cuckatoo31 = Cuckatoo31;

  double? _Cuckatoo32;
  double? get Cuckatoo32 => _$this._Cuckatoo32;
  set Cuckatoo32(double? Cuckatoo32) => _$this._Cuckatoo32 = Cuckatoo32;

  double? _CuckooCycle;
  double? get CuckooCycle => _$this._CuckooCycle;
  set CuckooCycle(double? CuckooCycle) => _$this._CuckooCycle = CuckooCycle;

  double? _CuckooCortex;
  double? get CuckooCortex => _$this._CuckooCortex;
  set CuckooCortex(double? CuckooCortex) => _$this._CuckooCortex = CuckooCortex;

  double? _Equihash;
  double? get Equihash => _$this._Equihash;
  set Equihash(double? Equihash) => _$this._Equihash = Equihash;

  double? _Equihash_125_4;
  double? get Equihash_125_4 => _$this._Equihash_125_4;
  set Equihash_125_4(double? Equihash_125_4) =>
      _$this._Equihash_125_4 = Equihash_125_4;

  double? _Equihash_144_5;
  double? get Equihash_144_5 => _$this._Equihash_144_5;
  set Equihash_144_5(double? Equihash_144_5) =>
      _$this._Equihash_144_5 = Equihash_144_5;

  double? _BeamHash;
  double? get BeamHash => _$this._BeamHash;
  set BeamHash(double? BeamHash) => _$this._BeamHash = BeamHash;

  double? _Ethash;
  double? get Ethash => _$this._Ethash;
  set Ethash(double? Ethash) => _$this._Ethash = Ethash;

  double? _Etchash;
  double? get Etchash => _$this._Etchash;
  set Etchash(double? Etchash) => _$this._Etchash = Etchash;

  double? _MTP;
  double? get MTP => _$this._MTP;
  set MTP(double? MTP) => _$this._MTP = MTP;

  double? _KAWPOW;
  double? get KAWPOW => _$this._KAWPOW;
  set KAWPOW(double? KAWPOW) => _$this._KAWPOW = KAWPOW;

  double? _RandomX;
  double? get RandomX => _$this._RandomX;
  set RandomX(double? RandomX) => _$this._RandomX = RandomX;

  double? _Eaglesong;
  double? get Eaglesong => _$this._Eaglesong;
  set Eaglesong(double? Eaglesong) => _$this._Eaglesong = Eaglesong;

  double? _Autolykos2;
  double? get Autolykos2 => _$this._Autolykos2;
  set Autolykos2(double? Autolykos2) => _$this._Autolykos2 = Autolykos2;

  AlgosBuilder();

  AlgosBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _Cuckarood29 = $v.Cuckarood29;
      _Cuckatoo31 = $v.Cuckatoo31;
      _Cuckatoo32 = $v.Cuckatoo32;
      _CuckooCycle = $v.CuckooCycle;
      _CuckooCortex = $v.CuckooCortex;
      _Equihash = $v.Equihash;
      _Equihash_125_4 = $v.Equihash_125_4;
      _Equihash_144_5 = $v.Equihash_144_5;
      _BeamHash = $v.BeamHash;
      _Ethash = $v.Ethash;
      _Etchash = $v.Etchash;
      _MTP = $v.MTP;
      _KAWPOW = $v.KAWPOW;
      _RandomX = $v.RandomX;
      _Eaglesong = $v.Eaglesong;
      _Autolykos2 = $v.Autolykos2;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Algos other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Algos;
  }

  @override
  void update(void Function(AlgosBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Algos build() {
    final _$result = _$v ??
        new _$Algos._(
            Cuckarood29: Cuckarood29,
            Cuckatoo31: Cuckatoo31,
            Cuckatoo32: Cuckatoo32,
            CuckooCycle: CuckooCycle,
            CuckooCortex: CuckooCortex,
            Equihash: Equihash,
            Equihash_125_4: Equihash_125_4,
            Equihash_144_5: Equihash_144_5,
            BeamHash: BeamHash,
            Ethash: Ethash,
            Etchash: Etchash,
            MTP: MTP,
            KAWPOW: KAWPOW,
            RandomX: RandomX,
            Eaglesong: Eaglesong,
            Autolykos2: Autolykos2);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
