// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HashAlgorithm.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<HashAlgorithm> _$hashAlgorithmSerializer =
    new _$HashAlgorithmSerializer();

class _$HashAlgorithmSerializer implements StructuredSerializer<HashAlgorithm> {
  @override
  final Iterable<Type> types = const [HashAlgorithm, _$HashAlgorithm];
  @override
  final String wireName = 'HashAlgorithm';

  @override
  Iterable<Object?> serialize(Serializers serializers, HashAlgorithm object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'coefficient',
      serializers.serialize(object.hashrateCoefficient,
          specifiedType: const FullType(int)),
    ];
    Object? value;
    value = object.hashrate;
    if (value != null) {
      result
        ..add('value')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    return result;
  }

  @override
  HashAlgorithm deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new HashAlgorithmBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'value':
          result.hashrate = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'coefficient':
          result.hashrateCoefficient = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$HashAlgorithm extends HashAlgorithm {
  @override
  final String name;
  @override
  final double? hashrate;
  @override
  final int hashrateCoefficient;

  factory _$HashAlgorithm([void Function(HashAlgorithmBuilder)? updates]) =>
      (new HashAlgorithmBuilder()..update(updates)).build();

  _$HashAlgorithm._(
      {required this.name, this.hashrate, required this.hashrateCoefficient})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, 'HashAlgorithm', 'name');
    BuiltValueNullFieldError.checkNotNull(
        hashrateCoefficient, 'HashAlgorithm', 'hashrateCoefficient');
  }

  @override
  HashAlgorithm rebuild(void Function(HashAlgorithmBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HashAlgorithmBuilder toBuilder() => new HashAlgorithmBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HashAlgorithm &&
        name == other.name &&
        hashrate == other.hashrate &&
        hashrateCoefficient == other.hashrateCoefficient;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, name.hashCode), hashrate.hashCode),
        hashrateCoefficient.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('HashAlgorithm')
          ..add('name', name)
          ..add('hashrate', hashrate)
          ..add('hashrateCoefficient', hashrateCoefficient))
        .toString();
  }
}

class HashAlgorithmBuilder
    implements Builder<HashAlgorithm, HashAlgorithmBuilder> {
  _$HashAlgorithm? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  double? _hashrate;
  double? get hashrate => _$this._hashrate;
  set hashrate(double? hashrate) => _$this._hashrate = hashrate;

  int? _hashrateCoefficient;
  int? get hashrateCoefficient => _$this._hashrateCoefficient;
  set hashrateCoefficient(int? hashrateCoefficient) =>
      _$this._hashrateCoefficient = hashrateCoefficient;

  HashAlgorithmBuilder();

  HashAlgorithmBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _hashrate = $v.hashrate;
      _hashrateCoefficient = $v.hashrateCoefficient;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HashAlgorithm other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$HashAlgorithm;
  }

  @override
  void update(void Function(HashAlgorithmBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$HashAlgorithm build() {
    final _$result = _$v ??
        new _$HashAlgorithm._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, 'HashAlgorithm', 'name'),
            hashrate: hashrate,
            hashrateCoefficient: BuiltValueNullFieldError.checkNotNull(
                hashrateCoefficient, 'HashAlgorithm', 'hashrateCoefficient'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
