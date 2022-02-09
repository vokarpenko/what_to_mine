import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';

class UsedGpuConverter extends TypeConverter<UsedGpu, String> {
  @override
  UsedGpu decode(String databaseValue) {
    return UsedGpu.fromJson(jsonDecode(databaseValue))!;
  }

  @override
  String encode(UsedGpu value) {
    return jsonEncode(value.toJson());
  }
}
