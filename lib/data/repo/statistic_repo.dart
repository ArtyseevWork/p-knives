import 'package:pknives/core/models/statItem.dart';
import 'package:pknives/data/storage/statistic_cloud_storage.dart';
import 'package:pknives/data/storage/statistic_local_storage.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/util/unix_time_helper.dart';

class StatisticRepo {

  Future<int> updateStatItem(StatItem statItem) async {
    int timeNow = getTimestamp();
    statItem.timestamp = timeNow;
    if (statItem.id == 0){
      statItem.id = timeNow;
    }
    if (Options.syncEnable){
      StatisticCloudStorage().updateStatItem(statItem);
    }
    return StatisticLocalStorage().updateStatItem(statItem);
  }

  Future<List<StatItem>> getAllStatisticByKnifeId(int knifeId) async {
    return StatisticLocalStorage().getAllStatisticByKnifeId(knifeId);
  }

  Future<List<StatItem>> getAllStatistic() async {
    return StatisticLocalStorage().getAllStatistic();
  }
}