import 'dart:io';

import 'package:pknives/data/storage/image_local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/models/imageDbRow.dart';

class ImageCloudStorage{


  Future<ImageDbRow> editImage(ImageDbRow imageDbRow) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${imageDbRow.name}';
    File imageFile = File(imagePath);
    if(imageDbRow.url != ""){
      await deleteImage(imageDbRow.url);
    }
    imageDbRow.url = await _uploadImage(imageFile, imageDbRow.name);
    await _editImageDbRow(imageDbRow);
    return imageDbRow;
  }

  Future<void> _editImageDbRow(ImageDbRow imageDbRow) async {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');
    final user = FirebaseAuth.instance.currentUser;
    final CollectionReference images = users.doc(user?.uid).collection('images');
    await images.doc(imageDbRow.id.toString()).set(
      imageDbRow.toMap(),
    ).then((value) {
      //print('Data added with ID: ${value.id}');
      // You can navigate back to the previous screen or display a success message
    }).catchError((error) {
      // Error adding data
      print('Failed to add data: $error');
    });
  }


  Future<List<ImageDbRow>> getAllImageDbRows() async {
    List<ImageDbRow> cloudImageDbRows = [];
    final user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> cloudKnivesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid.toString())
        .collection('images')
        .get();

    cloudImageDbRows = cloudKnivesSnapshot.docs
        .map((doc) => ImageDbRow.fromFirestore(doc))
        .toList();
    return cloudImageDbRows;
  }

  Future<String> _uploadImage(File imageFile, String fileName) async {
    try {
      // Получаем userId текущего пользователя
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Сохраняем изображение в папку пользователя
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$userId/$fileName.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print("_uploadImage error = $e");
      return "";
    }
  }

  Future<void> deleteImage(String downloadURL) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(downloadURL);
      await ref.delete();
      print('Изображение удалено успешно');
    } catch (e) {
      print('Ошибка при удалении изображения: $e');
    }
  }
}