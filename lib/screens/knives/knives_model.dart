import 'package:pknives/core/models/knife.dart';
import 'package:pknives/data/repo/knife_repo.dart';
import 'package:pknives/data/storage/demo_data.dart';
import 'package:share_plus/share_plus.dart';


class KnivesModel {
  Knife knife = Knife.getDefaultKnife();
  List<Knife> knives = [];

  Future<bool> onLoad() async{
    knives =  await KnifeRepo().getAllKnives();
    return true;
  }

  Future<void> addTestData() async{
   await DemoData().addDemoData();
   knives =  await KnifeRepo().getAllKnives();
  }

  Future<void> shareApp() async {
    final result = await Share.share(
        'Angle of knife: https://play.google.com/store'
            '/apps/details?id=com.mordansoft.angleofknife'
    );
    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing my website!');
    }
  }

}