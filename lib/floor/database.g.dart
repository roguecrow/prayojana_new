// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
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
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
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

  NotificationDao? _notificationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
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
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `notifications` (`id` INTEGER, `notification` TEXT NOT NULL, `isViewed` INTEGER NOT NULL, `title` TEXT NOT NULL, `data` TEXT NOT NULL, `sentTime` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  NotificationDao get notificationDao {
    return _notificationDaoInstance ??=
        _$NotificationDao(database, changeListener);
  }
}

class _$NotificationDao extends NotificationDao {
  _$NotificationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _appNotificationInsertionAdapter = InsertionAdapter(
            database,
            'notifications',
            (AppNotification item) => <String, Object?>{
                  'id': item.id,
                  'notification': item.notification,
                  'isViewed': item.isViewed ? 1 : 0,
                  'title': item.title,
                  'data': item.data,
                  'sentTime': item.sentTime
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppNotification> _appNotificationInsertionAdapter;

  @override
  Future<List<AppNotification>> findAllNotification() async {
    return _queryAdapter.queryList(
        'SELECT * FROM notifications ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => AppNotification(
            id: row['id'] as int?,
            title: row['title'] as String,
            data: row['data'] as String,
            sentTime: row['sentTime'] as String,
            notification: row['notification'] as String,
            isViewed: (row['isViewed'] as int) != 0));
  }

  @override
  Stream<AppNotification?> findNotificationById(int id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM notifications WHERE id = ?1',
        mapper: (Map<String, Object?> row) => AppNotification(
            id: row['id'] as int?,
            title: row['title'] as String,
            data: row['data'] as String,
            sentTime: row['sentTime'] as String,
            notification: row['notification'] as String,
            isViewed: (row['isViewed'] as int) != 0),
        arguments: [id],
        queryableName: 'notifications',
        isView: false);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM notifications WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteAllNotifications() async {
    await _queryAdapter.queryNoReturn('DELETE FROM notifications');
  }

  @override
  Future<List<AppNotification>> findUnviewedNotifications() async {
    return _queryAdapter.queryList(
        'SELECT * FROM notifications WHERE isViewed = 0',
        mapper: (Map<String, Object?> row) => AppNotification(
            id: row['id'] as int?,
            title: row['title'] as String,
            data: row['data'] as String,
            sentTime: row['sentTime'] as String,
            notification: row['notification'] as String,
            isViewed: (row['isViewed'] as int) != 0));
  }

  @override
  Future<void> markAllNotificationsAsViewed() async {
    await _queryAdapter.queryNoReturn('UPDATE notifications SET isViewed = 1');
  }

  @override
  Future<void> insertNotification(AppNotification notification) async {
    await _appNotificationInsertionAdapter.insert(
        notification, OnConflictStrategy.abort);
  }
}
