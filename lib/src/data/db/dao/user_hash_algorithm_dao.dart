import 'package:floor/floor.dart';
import 'package:what_to_mine/src/data/db/entities/user_hash_algorithm_entity.dart';

@dao
abstract class UserHashAlgorithmDao {
  @Query('SELECT * FROM user_hash_algorithm')
  Future<List<UserHashAlgorithmEntity>> selectAll();

  @Query('DELETE FROM user_hash_algorithm')
  Future<void> deleteAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(UserHashAlgorithmEntity entity);

  @Query('SELECT * FROM user_hash_algorithm WHERE id = :id')
  Future<UserHashAlgorithmEntity?> selectById(String id);

  @Query('DELETE FROM user_hash_algorithm WHERE id = :id')
  Future<void> deleteById(String id);
}
