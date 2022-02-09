import 'package:floor/floor.dart';
import 'package:what_to_mine/src/domain/algorithms/hash_algorithm.dart';

@Entity(tableName: 'user_hash_algorithm')
class UserHashAlgorithmEntity {
  @primaryKey
  final String id;

  final HashAlgorithm algorithm;

  UserHashAlgorithmEntity(this.algorithm) : id = algorithm.name;
}
