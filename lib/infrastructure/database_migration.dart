import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseMigration {
  static final _instance = DatabaseMigration._internal();
  static DatabaseMigration get = _instance;
  static Database _db;
  final List<String> initScripts = [
    '''
    CREATE TABLE users(
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL
    );
    '''
  ];
  List<String> migrationScripts = [];
  /*List<String> migrationScripts = [
    '''
    ALTER TABLE users ADD column age INTEGER NOT NULL DEFAULT 0;
    ''',
  ];*/

  DatabaseMigration._internal();

  Future<Database> db() async {
    if (_db == null) {
      _db = await _init();
    }
    return _db;
  }

  Future<Database> _init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'academic.db');
    int version = migrationScripts.length <= 0 ? 1 : migrationScripts.length + 1;
    print("Version: " + version.toString());
    var db = await openDatabase(
      path,
      version: version,
      onCreate: _createDb,
      onUpgrade: _upgradeDb
    );
    return db;
  }

  void _createDb(Database db, int newVersion) async {
    initScripts.forEach((script) async => await db.execute(script));
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    print('oldVersion: ' + oldVersion.toString());
    print('newVersion: ' + newVersion.toString());
    for (var i = oldVersion - 1; i < newVersion - 1; i++) {
      print('migrationScripts[i] => ' + i.toString());
      await db.execute(migrationScripts[i]);
    }
  }
}