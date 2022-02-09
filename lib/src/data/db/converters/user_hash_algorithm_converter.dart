import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';

class UserHashAlgorithmConverter extends TypeConverter<HashAlgorithm, String> {
  @override
  HashAlgorithm decode(String databaseValue) {
    return HashAlgorithm.fromJson(jsonDecode(databaseValue))!;
  }

  @override
  String encode(HashAlgorithm value) {
    return jsonEncode(value.toJson());
  }
}
