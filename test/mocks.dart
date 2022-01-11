import 'package:mockito/annotations.dart';
import 'package:what_to_mine/src/data/Gateway.dart';
import 'package:what_to_mine/src/data/Scheduler/BackgroundTaskScheduler.dart';
import 'package:what_to_mine/src/data/cache/MemoryStorage.dart';
import 'package:what_to_mine/src/data/client/MinerStatClient.dart';
import 'package:what_to_mine/src/data/db/AppDatabase.dart';
import 'package:what_to_mine/src/data/db/dao/UsedGpuDao.dart';
import 'package:what_to_mine/src/data/db/dao/UserHashAlgorithmDao.dart';
import 'package:what_to_mine/src/data/jsonReader/LocalJsonReader.dart';

// Все моки в одном месте, чтобы не генерировать лишних
// Запустить build_runner для генерации
@GenerateMocks([
  MemoryStorage,
  MinerStatClient,
  AppDatabase,
  LocalJsonReader,
  BackgroundTaskScheduler,
  Gateway,
  UsedGpuDao,
  UserHashAlgorithmDao
])
void main() {}