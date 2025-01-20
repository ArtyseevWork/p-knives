import 'package:pknives/core/models/knife.dart';
import 'package:pknives/core/models/status.dart';
import 'package:pknives/data/storage/knife_cloud_storage.dart';
import 'package:pknives/data/storage/knife_local_storage.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/util/unix_time_helper.dart';

class KnifeRepo{

  Future<Knife> updateKnife(Knife knife) async {
    int timeNow = getTimestamp();
    knife.timestamp = timeNow;
    if (knife.id == 0){
      knife.id = timeNow;
      knife.timestamp = timeNow;
      if (knife.status != Status.STATUS_NEW_DEMO){
        knife.status = Status.STATUS_NEW;
      }
    } else if (knife.status != Status.STATUS_DISABLE){
      knife.status = Status.STATUS_NORMAL;
    }
    KnifeLocalStorage().updateKnife(knife);
    if (Options.syncEnable){
      KnifeCloudStorage().updateKnife(knife);
    }
    return knife;
  }

  Future<Knife> getKnifeById(int id) async {
    return KnifeLocalStorage().getKnifeById(id);
  }

  Future<List<Knife>> getAllKnives() async {
    return KnifeLocalStorage().getAllKnives();
  }

  Future<void> deleteKnife(Knife knife) async {
    knife.status = Status.STATUS_DISABLE;
    await updateKnife(knife);
  }

}