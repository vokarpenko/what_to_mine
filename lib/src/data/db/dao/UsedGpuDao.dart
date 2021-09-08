import 'package:floor/floor.dart';
import 'package:what_to_mine/src/data/db/entities/UsedGpuEntity.dart';

@dao
abstract class UsedGpuDao {
  @Query('SELECT * FROM used_gpu')
  Future<List<UsedGpuEntity>> selectAll();

  @Query('DELETE FROM used_gpu')
  Future<void> deleteAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(UsedGpuEntity entity);

  @Query('SELECT * FROM used_gpu WHERE id = :id')
  Future<UsedGpuEntity?> selectById(String id);

  @Query('DELETE FROM used_gpu WHERE id = :id')
  Future<void> deleteById(String id);
}
