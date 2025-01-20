import 'dart:io';

import 'package:pknives/core/models/imageDbRow.dart';
import 'package:pknives/data/storage/image_cloud_storage.dart';
import 'package:pknives/data/storage/image_local_storage.dart';
import 'package:pknives/data/synchronization.dart';
import 'package:pknives/util/app_settings.dart';

class ImageRepo{

  Future<String> getImageByKnifeId(int knifeId) async{
    return ImageLocalStorage().getImagePathByKnifeId(knifeId);
  }

  Future<void> setImageForKnife(File? file, int knifeId) async {
    await ImageLocalStorage().setImageForKnife(file, knifeId);
    if (Options.syncEnable){
      Synchronization().syncImages();
    }
  }

  Future<void> deleteImageForKnife(int knifeId) async {
    try {
      ImageDbRow? imageDbRow = await ImageLocalStorage().getImageDbRowByKnifeId(knifeId);
      print ("imageDbRow!.url = ${imageDbRow!.url}");
      await ImageCloudStorage().deleteImage(imageDbRow!.url);
    } catch (e) {
      print ("deleteImageForKnife error : $e");
    }
    await ImageLocalStorage().deleteImageForKnife(knifeId);
    if (Options.syncEnable){
      Synchronization().syncImages();
    }
  }
}