import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:what_to_mine/src/data/db/converters/UsedGpuConverter.dart';

import 'dao/UsedGpuDao.dart';
import 'entities/UsedGpuEntity.dart';

part 'AppDatabase.g.dart';

@TypeConverters([UsedGpuConverter])
@Database(version: 1, entities: [UsedGpuEntity])
abstract class AppDatabase extends FloorDatabase {
  UsedGpuDao get usedGpuDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase.databaseBuilder('db').build();
  }
}
