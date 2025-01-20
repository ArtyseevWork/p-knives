
import 'package:pknives/core/models/knife.dart';
import '../../util/app_initializer.dart';


class SplashModel {
  bool finishDataLoad = false;

  Future <void> onLoad() async{
    await AppInitializer.initialize();
    finishDataLoad = true;
  }
}