import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:what_to_mine/src/data/db/converters/UsedGpuConverter.dart';
import 'package:what_to_mine/src/data/db/converters/UserHashAlgorithmConverter.dart';
import 'package:what_to_mine/src/data/db/dao/UserHashAlgorithmDao.dart';
import 'package:what_to_mine/src/data/db/entities/UserHashAlgorithmEntity.dart';

import 'dao/UsedGpuDao.dart';
import 'entities/UsedGpuEntity.dart';

part 'AppDatabase.g.dart';

@TypeConverters([UsedGpuConverter, UserHashAlgorithmConverter])
@Database(version: 1, entities: [UsedGpuEntity, UserHashAlgorithmEntity])
abstract class AppDatabase extends FloorDatabase {
  UsedGpuDao get usedGpuDao;
  UserHashAlgorithmDao get userHashAlgorithmDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase.databaseBuilder('db').build();
  }
}
