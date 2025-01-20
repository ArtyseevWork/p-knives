
import 'dart:io';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/core/models/statItem.dart';
import 'package:pknives/core/mvvm/view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'knife_model.dart';

class KnifeViewModel extends ViewModel {
  final KnifeModel _model = KnifeModel();

  Future<void> onLoad(Knife knife)  async{
    await _model.onLoad(knife);
    notify();
  }

  Future <void> deleteKnife() async {
    await _model.deleteKnife();
    notify();
  }

  Future <void> saveKnife(void Function() callback) async {
    await _model.saveKnife(callback);
  }

  Future <void> getImage(ImageSource imageSource) async {
    await _model.getImage(imageSource);
    notify();
  }

  Future<void> removeImage() async {
    await _model.removeImage();
    notify();
  }

  Knife          get knife        => _model.knife;
  List<StatItem> get statistic    => _model.statistic;
  File?          get imagePreview => _model.imagePreview;
}