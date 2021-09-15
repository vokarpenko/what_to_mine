// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AlgorithmHashrate.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Algorithm _$kawpow = const Algorithm._('kawpow');
const Algorithm _$ethash = const Algorithm._('ethash');

Algorithm _$algorithmValueOf(String name) {
  switch (name) {
    case 'kawpow':
      return _$kawpow;
    case 'ethash':
      return _$ethash;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<Algorithm> _$algorithmValues =
    new BuiltSet<Algorithm>(const <Algorithm>[
  _$kawpow,
  _$ethash,
]);

Serializer<AlgorithmHashrate> _$algorithmHashrateSerializer =
    new _$AlgorithmHashrateSerializer();
Serializer<Algorithm> _$algorithmSerializer = new _$AlgorithmSerializer();

class _$AlgorithmHashrateSerializer
    implements StructuredSerializer<AlgorithmHashrate> {
  @override
  final Iterable<Type> types = const [AlgorithmHashrate, _$AlgorithmHashrate];
  @override
  final String wireName = 'AlgorithmHashrate';

  @override
  Iterable<Object?> serialize(Serializers serializers, AlgorithmHashrate object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name,
          specifiedType: const FullType(Algorithm)),
      'value',
      serializers.serialize(object.value,
          specifiedType: const FullType(double)),
      'useDefault',
      serializers.serialize(object.useDefault,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  AlgorithmHashrate deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new AlgorithmHashrateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(Algorithm)) as Algorithm;
          break;
        case 'value':
          result.value = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'useDefault':
          result.useDefault = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$AlgorithmSerializer implements PrimitiveSerializer<Algorithm> {
  @override
  final Iterable<Type> types = const <Type>[Algorithm];
  @override
  final String wireName = 'Algorithm';

  @override
  Object serialize(Serializers serializers, Algorithm object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  Algorithm deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Algorithm.valueOf(serialized as String);
}

class _$AlgorithmHashrate extends AlgorithmHashrate {
  @override
  final Algorithm name;
  @override
  final double value;
  @override
  final bool useDefault;

  factory _$AlgorithmHashrate(
          [void Function(AlgorithmHashrateBuilder)? updates]) =>
      (new AlgorithmHashrateBuilder()..update(updates)).build();

  _$AlgorithmHashrate._(
      {required this.name, required this.value, required this.useDefault})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, 'AlgorithmHashrate', 'name');
    BuiltValueNullFieldError.checkNotNull(value, 'AlgorithmHashrate', 'value');
    BuiltValueNullFieldError.checkNotNull(
        useDefault, 'AlgorithmHashrate', 'useDefault');
  }

  @override
  AlgorithmHashrate rebuild(void Function(AlgorithmHashrateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AlgorithmHashrateBuilder toBuilder() =>
      new AlgorithmHashrateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AlgorithmHashrate &&
        name == other.name &&
        value == other.value &&
        useDefault == other.useDefault;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, name.hashCode), value.hashCode), useDefault.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('AlgorithmHashrate')
          ..add('name', name)
          ..add('value', value)
          ..add('useDefault', useDefault))
        .toString();
  }
}

class AlgorithmHashrateBuilder
    implements Builder<AlgorithmHashrate, AlgorithmHashrateBuilder> {
  _$AlgorithmHashrate? _$v;

  Algorithm? _name;
  Algorithm? get name => _$this._name;
  set name(Algorithm? name) => _$this._name = name;

  double? _value;
  double? get value => _$this._value;
  set value(double? value) => _$this._value = value;

  bool? _useDefault;
  bool? get useDefault => _$this._useDefault;
  set useDefault(bool? useDefault) => _$this._useDefault = useDefault;

  AlgorithmHashrateBuilder();

  AlgorithmHashrateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _value = $v.value;
      _useDefault = $v.useDefault;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AlgorithmHashrate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AlgorithmHashrate;
  }

  @override
  void update(void Function(AlgorithmHashrateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$AlgorithmHashrate build() {
    final _$result = _$v ??
        new _$AlgorithmHashrate._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, 'AlgorithmHashrate', 'name'),
            value: BuiltValueNullFieldError.checkNotNull(
                value, 'AlgorithmHashrate', 'value'),
            useDefault: BuiltValueNullFieldError.checkNotNull(
                useDefault, 'AlgorithmHashrate', 'useDefault'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
