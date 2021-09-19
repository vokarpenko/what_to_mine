// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UsedGpu.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<UsedGpu> _$usedGpuSerializer = new _$UsedGpuSerializer();

class _$UsedGpuSerializer implements StructuredSerializer<UsedGpu> {
  @override
  final Iterable<Type> types = const [UsedGpu, _$UsedGpu];
  @override
  final String wireName = 'UsedGpu';

  @override
  Iterable<Object?> serialize(Serializers serializers, UsedGpu object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'gpuData',
      serializers.serialize(object.gpuData, specifiedType: const FullType(Gpu)),
      'quantity',
      serializers.serialize(object.quantity,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  UsedGpu deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new UsedGpuBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'gpuData':
          result.gpuData.replace(serializers.deserialize(value,
              specifiedType: const FullType(Gpu))! as Gpu);
          break;
        case 'quantity':
          result.quantity = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$UsedGpu extends UsedGpu {
  @override
  final Gpu gpuData;
  @override
  final int quantity;

  factory _$UsedGpu([void Function(UsedGpuBuilder)? updates]) =>
      (new UsedGpuBuilder()..update(updates)).build();

  _$UsedGpu._({required this.gpuData, required this.quantity}) : super._() {
    BuiltValueNullFieldError.checkNotNull(gpuData, 'UsedGpu', 'gpuData');
    BuiltValueNullFieldError.checkNotNull(quantity, 'UsedGpu', 'quantity');
  }

  @override
  UsedGpu rebuild(void Function(UsedGpuBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UsedGpuBuilder toBuilder() => new UsedGpuBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsedGpu &&
        gpuData == other.gpuData &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, gpuData.hashCode), quantity.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('UsedGpu')
          ..add('gpuData', gpuData)
          ..add('quantity', quantity))
        .toString();
  }
}

class UsedGpuBuilder implements Builder<UsedGpu, UsedGpuBuilder> {
  _$UsedGpu? _$v;

  GpuBuilder? _gpuData;
  GpuBuilder get gpuData => _$this._gpuData ??= new GpuBuilder();
  set gpuData(GpuBuilder? gpuData) => _$this._gpuData = gpuData;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  UsedGpuBuilder();

  UsedGpuBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _gpuData = $v.gpuData.toBuilder();
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UsedGpu other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UsedGpu;
  }

  @override
  void update(void Function(UsedGpuBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$UsedGpu build() {
    _$UsedGpu _$result;
    try {
      _$result = _$v ??
          new _$UsedGpu._(
              gpuData: gpuData.build(),
              quantity: BuiltValueNullFieldError.checkNotNull(
                  quantity, 'UsedGpu', 'quantity'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'gpuData';
        gpuData.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'UsedGpu', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
