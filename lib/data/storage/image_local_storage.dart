import 'dart:io';
import 'package:pknives/core/models/imageDbRow.dart';
import 'package:pknives/data/database.dart';
import 'package:pknives/util/file_helper.dart';
import 'package:pknives/util/unix_time_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;


class ImageLocalStorage{

  Future<String> getImagePathByKnifeId(int knifeId) async{
    ImageDbRow? imageDbRow = await getImageDbRowByKnifeId(knifeId);
    if (imageDbRow != null && imageDbRow.name.isNotEmpty){
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${imageDbRow.name}';
      return imagePath;
    } else{
      return "";
    }
  }


  Future<void> setImageFromCloud(ImageDbRow imageDbRow) async { // for sync
    final directory = await getApplicationDocumentsDirectory();
    String imagePath = '${directory.path}/${imageDbRow.name}';
    File? file = await FileHelper.downloadFileFromUrl(imageDbRow.url);
    if(file!= null && await FileHelper.writeFileToPath(file, imagePath)){
      await _updateImageRow(imageDbRow, true);
      _updateImageRow(imageDbRow, false);
    }
  }


  Future<void> setImageForKnife(File? file, int knifeId) async {
    if (file == null) {
      print('Файл не найден'); //todo delete
      return;
    }
    final fileName = _getUniqueImageName();
    final directory = await getApplicationDocumentsDirectory();
    ImageDbRow? imageDbRow = await getImageDbRowByKnifeId(knifeId);
    if (imageDbRow != null){
      imageDbRow.timestamp = getTimestamp();
      FileHelper.deleteFileFromPath('${directory.path}/${imageDbRow.name}');
      imageDbRow.name = fileName;
    } else {
      imageDbRow = ImageDbRow(
          getTimestamp(),
          knifeId,
          fileName,
          "",
          getTimestamp()
      );
    }
    String imagePath = '${directory.path}/$fileName';
    if(await FileHelper.writeFileToPath(file, imagePath)){
      await _updateImageRow(imageDbRow, true);
    }
  }


  String _getUniqueImageName() {
    return'aok_img_${DateTime.now().millisecondsSinceEpoch}';
  }


  Future<void> _updateImageRow(ImageDbRow imageDbRow, bool withSync) async {
    int timeNow = getTimestamp();
    if (imageDbRow.id == 0){
      imageDbRow.timestamp = timeNow;
      imageDbRow.id = timeNow;
    }
    final Database db = await ApplicationDatabase().database;
    if (withSync == true){
      imageDbRow.timestamp = timeNow;
    }
    await db.insert(
        ApplicationDatabase.tableImagesName,
        imageDbRow.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
    print ("updateImageRow done");
  }


  Future<List<ImageDbRow>> getAllImageDbRows() async {
    final Database db = await ApplicationDatabase().database;

    final List<Map<String, dynamic>> rows = await db.query(
      ApplicationDatabase.tableImagesName,
      orderBy: '_id DESC',
    );

    if (rows.isNotEmpty) {
      return List.generate(rows.length, (i) {
        return ImageDbRow.fromMap(rows[i]);
      });
    } else {
      return [];
    }
  }


  Future<ImageDbRow?> getImageDbRowByKnifeId(int knifeId) async {
    final Database db = await ApplicationDatabase().database;

    final List<Map<String, dynamic>> rows = await db.query(
      ApplicationDatabase.tableImagesName,
      where: 'knife_id = ?',
      whereArgs: [knifeId],
      orderBy: '_id DESC',
    );

    if (rows.isNotEmpty) {
      return ImageDbRow.fromMap(rows[0]);
    } else {
      print('getImageDbRowByKnifeId: Запись с knife_id $knifeId не найдена');
      return null;
    }
  }


  Future<void> deleteImageForKnife(int knifeId) async {
    final directory = await getApplicationDocumentsDirectory();
    ImageDbRow? imageDbRow = await getImageDbRowByKnifeId(knifeId);
    if (imageDbRow != null){
      imageDbRow.timestamp = getTimestamp();
      imageDbRow.name = "";
      String imagePath = '${directory.path}/${imageDbRow.name}';
      await FileHelper.deleteFileFromPath(imagePath);
      await _updateImageRow(imageDbRow, true);
    }
  }



}