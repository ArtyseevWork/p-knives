import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

const double upscaleIndex = 1;
const double thumbCoefficient = 0.3;


String resizeBase64Image(String base64Image, double coefficient) {
  Uint8List imageData = base64Decode(base64Image);
  Uint8List resizedImage = resizeUint8ListImage(imageData, coefficient);
  String resizedBase64Data = base64Encode(resizedImage);
  return resizedBase64Data;
}


Uint8List convertBase64ToUint8List(String base64Image){
  return base64Decode(base64Image);
}


Uint8List resizeUint8ListImage(Uint8List imageData, double coefficient) {
  img.Image image = img.decodeImage(imageData)!;

  img.Image resizedImage = img.copyResize(
    image,
    width: (image.width * coefficient).toInt(),
    height: (image.height * coefficient).toInt(),
  );
  return img.encodeJpg(resizedImage);
}


Future<String> saveUint8ListToFile(Uint8List decodedBytes, {String? fileName}) async {
  fileName ??= getUniqueImageName();
  String filePath = await getFilePath(fileName);
  final File file = File(filePath);
  await file.writeAsBytes(decodedBytes);
  return (fileName);
}


Future<String> getFilePath(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  String filePath = '${directory.path}/$fileName';
  return filePath;
}


void deleteFile(String filePath) async {
  try {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    } else {
    }
  } catch (e) {
    print("deleteFile Error : $e");
  }
}


String getUniqueImageName() {
  return'aok_img_${DateTime.now().millisecondsSinceEpoch}';
}

Future<String> generateThumbnail(
  Uint8List uint8List,
  {String? fileName}) async{
  fileName ??= getUniqueImageName();
  Uint8List resizedUint8List = resizeUint8ListImage(uint8List, thumbCoefficient);
  await saveUint8ListToFile(resizedUint8List, fileName: fileName);
  return fileName;
}


Future<String> saveImageToTemporaryFile(Uint8List bytes) async {
  try {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imageFile = File('${directory.path}/temp_image_$timestamp.jpg');
    await imageFile.writeAsBytes(bytes);
    return imageFile.path;
  } catch (e) {
    print('Failed to save image to temporary file: $e');
    return "";
  }
}


Future<String> saveFileToTemporaryDirectory(String sourcePath) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/${sourcePath.split('/').last}.jpg';
    await File(sourcePath).copy(tempFilePath);
    return tempFilePath;
  } catch (e) {
    print('Failed to save file to temporary directory: $e');
    return "";
  }
}


Future<ui.Image> loadImage(String imagePath) async {
  final ByteData data = await rootBundle.load(imagePath);
  final Uint8List bytes = data.buffer.asUint8List();
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}
