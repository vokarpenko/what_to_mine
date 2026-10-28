import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';

// Floor marks the converters used by the existing database schema experimental.
// ignore: experimental_member_use
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
