import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;


class FileHelper{

  static Future<bool> writeFileToPath(File file, String path) async {
    try {
      final File destinationFile = File(path);

      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }

      await file.copy(path);
      print('Файл успешно записан по пути: $path');
      return true;
    } catch (e) {
      print('Ошибка при записи файла: $e');
      return false;
    }
  }

  static Future<void> deleteFileFromPath(String path) async {
    try {
      final File destinationFile = File(path);

      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }
    } catch (e) {
      print('Ошибка при удалении файла: $e');
    }
  }

  static Future<File?> downloadFileFromUrl(String imageUrl) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();

      final String fileName = path.basename(imageUrl);

      final String filePath = path.join(tempDir.path, fileName);

      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final File file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        return file;
      } else {
        print('Ошибка загрузки файла: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка при загрузке файла: $e');
      return null;
    }
  }

}