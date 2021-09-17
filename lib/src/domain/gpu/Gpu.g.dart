// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Gpu.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Gpu> _$gpuSerializer = new _$GpuSerializer();

class _$GpuSerializer implements StructuredSerializer<Gpu> {
  @override
  final Iterable<Type> types = const [Gpu, _$Gpu];
  @override
  final String wireName = 'Gpu';

  @override
  Iterable<Object?> serialize(Serializers serializers, Gpu object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'marketingName',
      serializers.serialize(object.marketingName,
          specifiedType: const FullType(String)),
      'vendor',
      serializers.serialize(object.vendor,
          specifiedType: const FullType(String)),
      'price',
      serializers.serialize(object.price, specifiedType: const FullType(int)),
      'secondHand',
      serializers.serialize(object.secondHand,
          specifiedType: const FullType(bool)),
      'algos',
      serializers.serialize(object.hashAlgorithms,
          specifiedType:
              const FullType(BuiltList, const [const FullType(HashAlgorithm)])),
    ];

    return result;
  }

  @override
  Gpu deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GpuBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'marketingName':
          result.marketingName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'vendor':
          result.vendor = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'price':
          result.price = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'secondHand':
          result.secondHand = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
        case 'algos':
          result.hashAlgorithms.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(HashAlgorithm)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$Gpu extends Gpu {
  @override
  final String id;
  @override
  final String name;
  @override
  final String marketingName;
  @override
  final String vendor;
  @override
  final int price;
  @override
  final bool secondHand;
  @override
  final BuiltList<HashAlgorithm> hashAlgorithms;

  factory _$Gpu([void Function(GpuBuilder)? updates]) =>
      (new GpuBuilder()..update(updates)).build();

  _$Gpu._(
      {required this.id,
      required this.name,
      required this.marketingName,
      required this.vendor,
      required this.price,
      required this.secondHand,
      required this.hashAlgorithms})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, 'Gpu', 'id');
    BuiltValueNullFieldError.checkNotNull(name, 'Gpu', 'name');
    BuiltValueNullFieldError.checkNotNull(
        marketingName, 'Gpu', 'marketingName');
    BuiltValueNullFieldError.checkNotNull(vendor, 'Gpu', 'vendor');
    BuiltValueNullFieldError.checkNotNull(price, 'Gpu', 'price');
    BuiltValueNullFieldError.checkNotNull(secondHand, 'Gpu', 'secondHand');
    BuiltValueNullFieldError.checkNotNull(
        hashAlgorithms, 'Gpu', 'hashAlgorithms');
  }

  @override
  Gpu rebuild(void Function(GpuBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GpuBuilder toBuilder() => new GpuBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Gpu &&
        id == other.id &&
        name == other.name &&
        marketingName == other.marketingName &&
        vendor == other.vendor &&
        price == other.price &&
        secondHand == other.secondHand &&
        hashAlgorithms == other.hashAlgorithms;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc($jc(0, id.hashCode), name.hashCode),
                        marketingName.hashCode),
                    vendor.hashCode),
                price.hashCode),
            secondHand.hashCode),
        hashAlgorithms.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Gpu')
          ..add('id', id)
          ..add('name', name)
          ..add('marketingName', marketingName)
          ..add('vendor', vendor)
          ..add('price', price)
          ..add('secondHand', secondHand)
          ..add('hashAlgorithms', hashAlgorithms))
        .toString();
  }
}

class GpuBuilder implements Builder<Gpu, GpuBuilder> {
  _$Gpu? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _marketingName;
  String? get marketingName => _$this._marketingName;
  set marketingName(String? marketingName) =>
      _$this._marketingName = marketingName;

  String? _vendor;
  String? get vendor => _$this._vendor;
  set vendor(String? vendor) => _$this._vendor = vendor;

  int? _price;
  int? get price => _$this._price;
  set price(int? price) => _$this._price = price;

  bool? _secondHand;
  bool? get secondHand => _$this._secondHand;
  set secondHand(bool? secondHand) => _$this._secondHand = secondHand;

  ListBuilder<HashAlgorithm>? _hashAlgorithms;
  ListBuilder<HashAlgorithm> get hashAlgorithms =>
      _$this._hashAlgorithms ??= new ListBuilder<HashAlgorithm>();
  set hashAlgorithms(ListBuilder<HashAlgorithm>? hashAlgorithms) =>
      _$this._hashAlgorithms = hashAlgorithms;

  GpuBuilder();

  GpuBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _marketingName = $v.marketingName;
      _vendor = $v.vendor;
      _price = $v.price;
      _secondHand = $v.secondHand;
      _hashAlgorithms = $v.hashAlgorithms.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Gpu other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Gpu;
  }

  @override
  void update(void Function(GpuBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Gpu build() {
    _$Gpu _$result;
    try {
      _$result = _$v ??
          new _$Gpu._(
              id: BuiltValueNullFieldError.checkNotNull(id, 'Gpu', 'id'),
              name: BuiltValueNullFieldError.checkNotNull(name, 'Gpu', 'name'),
              marketingName: BuiltValueNullFieldError.checkNotNull(
                  marketingName, 'Gpu', 'marketingName'),
              vendor: BuiltValueNullFieldError.checkNotNull(
                  vendor, 'Gpu', 'vendor'),
              price:
                  BuiltValueNullFieldError.checkNotNull(price, 'Gpu', 'price'),
              secondHand: BuiltValueNullFieldError.checkNotNull(
                  secondHand, 'Gpu', 'secondHand'),
              hashAlgorithms: hashAlgorithms.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'hashAlgorithms';
        hashAlgorithms.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Gpu', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
