// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) => _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() => _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null ? await sqfliteDatabaseFactory.getDatabasePath(name!) : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UsedGpuDao? _usedGpuDaoInstance;

  UserHashAlgorithmDao? _userHashAlgorithmDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations, [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `used_gpu` (`id` TEXT NOT NULL, `usedGpu` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `user_hash_algorithm` (`id` TEXT NOT NULL, `algorithm` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UsedGpuDao get usedGpuDao {
    return _usedGpuDaoInstance ??= _$UsedGpuDao(database, changeListener);
  }

  @override
  UserHashAlgorithmDao get userHashAlgorithmDao {
    return _userHashAlgorithmDaoInstance ??= _$UserHashAlgorithmDao(database, changeListener);
  }
}

class _$UsedGpuDao extends UsedGpuDao {
  _$UsedGpuDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _usedGpuEntityInsertionAdapter = InsertionAdapter(
            database,
            'used_gpu',
            (UsedGpuEntity item) =>
                <String, Object?>{'id': item.id, 'usedGpu': _usedGpuConverter.encode(item.usedGpu)});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UsedGpuEntity> _usedGpuEntityInsertionAdapter;

  @override
  Future<List<UsedGpuEntity>> selectAll() async {
    return _queryAdapter.queryList('SELECT * FROM used_gpu',
        mapper: (Map<String, Object?> row) => UsedGpuEntity(_usedGpuConverter.decode(row['usedGpu'] as String)));
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM used_gpu');
  }

  @override
  Future<UsedGpuEntity?> selectById(String id) async {
    return _queryAdapter.query('SELECT * FROM used_gpu WHERE id = ?1',
        mapper: (Map<String, Object?> row) => UsedGpuEntity(_usedGpuConverter.decode(row['usedGpu'] as String)),
        arguments: [id]);
  }

  @override
  Future<void> deleteById(String id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM used_gpu WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insert(UsedGpuEntity entity) async {
    await _usedGpuEntityInsertionAdapter.insert(entity, OnConflictStrategy.replace);
  }
}

class _$UserHashAlgorithmDao extends UserHashAlgorithmDao {
  _$UserHashAlgorithmDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _userHashAlgorithmEntityInsertionAdapter = InsertionAdapter(
            database,
            'user_hash_algorithm',
            (UserHashAlgorithmEntity item) =>
                <String, Object?>{'id': item.id, 'algorithm': _userHashAlgorithmConverter.encode(item.algorithm)});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserHashAlgorithmEntity> _userHashAlgorithmEntityInsertionAdapter;

  @override
  Future<List<UserHashAlgorithmEntity>> selectAll() async {
    return _queryAdapter.queryList('SELECT * FROM user_hash_algorithm',
        mapper: (Map<String, Object?> row) =>
            UserHashAlgorithmEntity(_userHashAlgorithmConverter.decode(row['algorithm'] as String)));
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM user_hash_algorithm');
  }

  @override
  Future<UserHashAlgorithmEntity?> selectById(String id) async {
    return _queryAdapter.query('SELECT * FROM user_hash_algorithm WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            UserHashAlgorithmEntity(_userHashAlgorithmConverter.decode(row['algorithm'] as String)),
        arguments: [id]);
  }

  @override
  Future<void> deleteById(String id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM user_hash_algorithm WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insert(UserHashAlgorithmEntity entity) async {
    await _userHashAlgorithmEntityInsertionAdapter.insert(entity, OnConflictStrategy.replace);
  }
}

// ignore_for_file: unused_element
final _usedGpuConverter = UsedGpuConverter();
final _userHashAlgorithmConverter = UserHashAlgorithmConverter();
