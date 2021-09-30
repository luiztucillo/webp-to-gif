import 'package:sqflite/sqflite.dart';

class DbService {
  static final DbService _instance = DbService._internalConstructor();

  Database? _db;

  factory DbService() {
    return _instance;
  }

  DbService._internalConstructor();

  init() async {
    var databasesPath = await getDatabasesPath();
    var path = '$databasesPath/my_db.db';

    // await deleteDatabase(path);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();
        _createDb(batch);
        await batch.commit();
      },
    );
  }

  Future<int?> insert(String table, Map<String, dynamic> values) async {
    return await _db?.insert(table, values,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<bool> update(String table, Map<String, dynamic> values) async {
    int? rowsUpdated = await _db
        ?.update(table, values, where: 'id = ?', whereArgs: [values['id']]);

    if (rowsUpdated == null) {
      return false;
    }

    return rowsUpdated > 0;
  }

  Future<bool> deleteWhere(String table, String where, List<dynamic> whereArgs) async {
    var result = await _db?.delete(table, where: where, whereArgs: [whereArgs]);

    if (result == null) {
      return false;
    }

    return result > 0;
  }

  Future<bool> delete(String table, int id) async {
    var result = await _db?.delete(table, where: 'id = ?', whereArgs: [id]);

    if (result == null) {
      return false;
    }

    return result > 0;
  }

  Future<List<Map<String, dynamic>>?> query(
    String table,
    List<String> columns, {
    int? limit,
    int? offset,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    return await _db?.query(
      table,
      columns: columns,
      limit: limit,
      offset: offset,
      where: where,
      whereArgs: whereArgs,
    );
  }

  void _createDb(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS folders');
    batch.execute('''
    CREATE TABLE folders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    color TEXT
    )''');

    batch.execute('DROP TABLE IF EXISTS images');
    batch.execute('''
    CREATE TABLE images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file TEXT,
    converted INTEGER,
    folder_id INTEGER
    )''');
  }
}
