import 'dart:async';
import 'package:pknives/util/unix_time_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ApplicationDatabase {
  late Future<Database> database;
  late bool failed;
  static const String tableKnivesName ="KNIVES";
  static const String tableStatisticName ="STAT";
  static const String tableImagesName ="IMAGES";
  final int ver = 14;
  static final ApplicationDatabase _instance = ApplicationDatabase._();

  factory ApplicationDatabase() {
    return _instance;
  }

  ApplicationDatabase._() {
    failed = false;
    database = _initDB('db_angle_of_knife');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
        path,
        version: ver,
        onCreate: _createDB,
        onUpgrade: _updateDB,
        onDowngrade: (x,y,z){});
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute("CREATE TABLE " + tableKnivesName + " ("
        + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "name TEXT,"
        + "description TEXT,"
        + "angle NUMERIC,"
        + "status INTEGER,"
        + "double_side_sharpening INTEGER,"
        + "timestamp Numeric)"
      );

      await _createStatTable(db);
      await _createImagesTable(db);

    } catch (e) {
      print("Create database error : $e");
      failed = true;
    }
  }

  Future<void> _updateDB(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 14){
        await _createStatTable(db);
        await _createImagesTable(db);
        await migrateDB(db);
      }
    } catch (e) {
      print("Update database error : $e");
      failed = true;
    }
  }

  Future<void> _createStatTable(Database db) async {
    try {
      await db.execute("CREATE TABLE " + tableStatisticName + " ("
          + "_id INTEGER PRIMARY KEY, "
          + "knife_id integer,"
          + "angle NUMERIC,"
          + "timestamp integer,"
          + "status integer,"
          + "date NUMERIC)"
      );
    } catch (e) {
      print("_createStatTable error : $e");
      failed = true;
    }
  }

  Future<void> _createImagesTable(Database db) async {
    try {
      await db.execute("CREATE TABLE " + tableImagesName + " ("
          + "_id INTEGER PRIMARY KEY,"
          + "knife_id INTEGER,"
          + "name TEXT,"
          + "url TEXT,"
          + "timestamp INTEGER)"
      );
    } catch (e) {
      print("_createImagesTable error : $e");
      failed = true;
    }
  }

  Future<void> migrateDB(Database db) async {
    await db.transaction((txn) async {
      try {
        await txn.execute("CREATE TABLE knives_new ("
            + "_id INTEGER PRIMARY KEY, "
            + "name TEXT, "
            + "description TEXT, "
            + "angle NUMERIC, "
            + "status INTEGER, "
            + "double_side_sharpening INTEGER, "
            + "timestamp INTEGER)"
        );

        int timestamp = getTimestamp();

        await txn.execute('''
          INSERT INTO knives_new (_id, name, description, angle, status,  double_side_sharpening, timestamp)
          SELECT                  _id, name, description, angle, status,  double_side_sharpening, '$timestamp'
          FROM $tableKnivesName
        ''');

        await txn.execute("DROP TABLE $tableKnivesName");
        await txn.execute("ALTER TABLE knives_new RENAME TO $tableKnivesName");

        print("Миграция базы данных выполнена успешно.");
      } catch (e) {
        print("Ошибка при миграции базы данных: $e");
        rethrow;
      }
    });
  }

}