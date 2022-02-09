import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:what_to_mine/src/data/db/dao/used_gpu_dao.dart';
import 'package:what_to_mine/src/data/db/dao/user_hash_algorithm_dao.dart';

import 'converters/used_gpu_converter.dart';
import 'converters/user_hash_algorithm_converter.dart';
import 'entities/used_gpu_entity.dart';
import 'entities/user_hash_algorithm_entity.dart';

part 'app_database.g.dart';

@TypeConverters([UsedGpuConverter, UserHashAlgorithmConverter])
@Database(version: 1, entities: [UsedGpuEntity, UserHashAlgorithmEntity])
abstract class AppDatabase extends FloorDatabase {
  UsedGpuDao get usedGpuDao;

  UserHashAlgorithmDao get userHashAlgorithmDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase.databaseBuilder('db').build();
  }
}
