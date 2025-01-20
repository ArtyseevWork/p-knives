import 'dart:io';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/core/models/statItem.dart';
import 'package:pknives/data/repo/image_repo.dart';
import 'package:pknives/data/repo/knife_repo.dart';
import 'package:pknives/data/repo/statistic_repo.dart';
import 'package:image_picker/image_picker.dart';

class KnifeModel {
  late Knife knife;
  List<StatItem> statistic = [];
  File? imagePreview;
  double previewImageSize = 512;
  int previewImageQuality = 50;


  Future <void> onLoad(Knife knife) async{
    this.knife = knife;
    String previewPath = await ImageRepo().getImageByKnifeId(knife.id);
    if(knife.image != ""){
      imagePreview = File(previewPath);
    }
    statistic = await StatisticRepo().getAllStatisticByKnifeId(knife.id);
  }

  Future <void> deleteKnife() async {
    await KnifeRepo().deleteKnife(knife);
  }

  Future <void> saveKnife(void Function() callback) async {
    if (knife != Knife.getDefaultKnife()){
      await KnifeRepo().updateKnife(knife);
    }
    callback();
  }

  Future<File?> getImage(ImageSource imageSource) async {
    final ImagePicker imagePicker = ImagePicker();
    try {
      XFile? xFile = await imagePicker.pickImage(
        source: imageSource,
        maxHeight: previewImageSize,
        maxWidth: previewImageSize,
        imageQuality: previewImageQuality,
      );

      if (xFile == null) {
        print('Изображение не выбрано');
        return null;
      }

      if (knife == Knife.getDefaultKnife()){
        knife = await KnifeRepo().updateKnife(knife);
      }

      setImagePreview(xFile.path);
      await ImageRepo().setImageForKnife(imagePreview, knife.id);
    } catch (e) {
      print('Ошибка при выборе изображения: $e');
      return null;
    }
  }

  Future<void> removeImage() async {
    await ImageRepo().deleteImageForKnife(knife.id);
    imagePreview= null;
  }

  setImagePreview(String xFilePath) {
    imagePreview = File(xFilePath);
  }

}