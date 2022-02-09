import 'package:mockito/annotations.dart';
import 'package:what_to_mine/src/data/cache/memory_storage.dart';
import 'package:what_to_mine/src/data/client/miner_stat_client.dart';
import 'package:what_to_mine/src/data/db/app_database.dart';
import 'package:what_to_mine/src/data/db/dao/used_gpu_dao.dart';
import 'package:what_to_mine/src/data/db/dao/user_hash_algorithm_dao.dart';
import 'package:what_to_mine/src/data/gateway.dart';
import 'package:what_to_mine/src/data/json_reader/json_reader.dart';
import 'package:what_to_mine/src/utils/scheduler/background_task_scheduler.dart';

// Все моки в одном месте, чтобы не генерировать лишних
// Запустить build_runner для генерации
@GenerateMocks([
  MemoryStorage,
  MinerStatClient,
  AppDatabase,
  JsonReader,
  BackgroundTaskScheduler,
  Gateway,
  UsedGpuDao,
  UserHashAlgorithmDao
])
void main() {}
