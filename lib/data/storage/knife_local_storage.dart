
import 'package:sqflite/sqflite.dart';

import '../../core/models/knife.dart';
import '../../core/models/status.dart';
import '../../values/strings/localizer.dart';
import '../database.dart';

class KnifeLocalStorage {
  final String columnId = '_id';

  Future<int> updateKnife(Knife knife) async {
    final Database db = await ApplicationDatabase().database;
    return await db.insert(
        ApplicationDatabase.tableKnivesName,
        knife.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }


  Future<Knife> getKnifeById(int id) async {
    final Database db = await ApplicationDatabase().database;
    final List<Map<String, dynamic>> maps = await db.query(
      ApplicationDatabase.tableKnivesName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return await Knife.fromMapAsync(maps[0]);
    } else {
      throw Exception("Knife with id $id not found");
    }
  }

  Future<List<Knife>> getAllKnives() async {
    String query = "status < ${Status.STATUS_DISABLE}";
    final Database db = await ApplicationDatabase().database;
    final List<Map<String, dynamic>> rows = await db.query(
      ApplicationDatabase.tableKnivesName,
      where: query,
      orderBy: '$columnId DESC',
    );

    // Используем Future.wait, чтобы подождать завершения всех асинхронных операций
    return await Future.wait(rows.map((row) async {
      return await Knife.fromMapAsync(row);
    }).toList());
  }



}