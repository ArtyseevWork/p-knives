import 'package:pknives/core/models/statItem.dart';
import 'package:sqflite/sqflite.dart';
import '../database.dart';

class StatisticLocalStorage {
  final String columnId          = '_id';
  final String columnKnifeId     = 'knife_id';
  final String columnDate        = 'date';
  final String columnAngle       = 'angle';

  Future<int> updateStatItem(StatItem statItem) async {
    final Database db = await ApplicationDatabase().database;
    return await db.insert(
        ApplicationDatabase.tableStatisticName,
        statItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }



  Future<List<StatItem>> getAllStatisticByKnifeId(int knifeId) async {
    String query = "knife_id == $knifeId";
    final Database db = await ApplicationDatabase().database;
    final List<Map<String, dynamic>> rows = await db.query(
      ApplicationDatabase.tableStatisticName,
      where: query,
      orderBy: '$columnId DESC',
    );
    return List.generate(rows.length, (i) {
      return StatItem.fromMap(rows[i]);
    });
  }

  Future<List<StatItem>> getAllStatistic() async {
    final Database db = await ApplicationDatabase().database;
    final List<Map<String, dynamic>> rows = await db.query(
      ApplicationDatabase.tableStatisticName,
      orderBy: '$columnId DESC',
    );
    return List.generate(rows.length, (i) {
      return StatItem.fromMap(rows[i]);
    });
  }

}