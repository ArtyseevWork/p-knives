import 'package:pknives/core/models/imageDbRow.dart';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/core/models/statItem.dart';
import 'package:pknives/core/models/status.dart';
import 'package:pknives/data/storage/image_cloud_storage.dart';
import 'package:pknives/data/storage/image_local_storage.dart';
import 'package:pknives/data/storage/knife_cloud_storage.dart';
import 'package:pknives/data/storage/knife_local_storage.dart';
import 'package:pknives/data/storage/statistic_cloud_storage.dart';
import 'package:pknives/data/storage/statistic_local_storage.dart';

import '../util/app_settings.dart';

class Synchronization{

  syncAll(){
    if (Options.syncEnable){
      _syncImages();
      _syncKnives();
      _syncStats();
    }
  }

  Future<void> syncAllAsync() async{
    if (Options.syncEnable){
      await _syncImages();
      await _syncKnives();
      await _syncStats();
    }
  }

  syncImages(){
    if (Options.syncEnable){
      _syncImages();
    }
  }


  Future<void> _syncKnives() async {
    List<Knife> localKnives = await KnifeLocalStorage().getAllKnives();
    List<Knife> cloudKnives = await KnifeCloudStorage().getAllKnives();

    for (var localKnife in localKnives) {
      bool existsInCloud = cloudKnives.any(
              (cloudKnife) => (
                     cloudKnife.id == localKnife.id
                  && localKnife.timestamp <= cloudKnife.timestamp
              )
      );
      if (!existsInCloud && localKnife.status != Status.STATUS_NEW_DEMO) {
        await KnifeCloudStorage().updateKnife(localKnife);
      }
    }

    for (var cloudKnife in cloudKnives) {
      bool existsLocally = localKnives.any(
              (localKnife) => (
                     localKnife.id == cloudKnife.id
                  && localKnife.timestamp >= cloudKnife.timestamp
              )
      );
      if (!existsLocally && cloudKnife.status != Status.STATUS_NEW_DEMO) {
        await KnifeLocalStorage().updateKnife(cloudKnife);
      }
    }
  }


  Future<void> _syncStats() async {
    List<StatItem> localStatItems = await StatisticLocalStorage().getAllStatistic();
    List<StatItem> cloudStatItems = await StatisticCloudStorage().getAllStatistic();

    for (var localStatItem in localStatItems) {
      bool existsInCloud = cloudStatItems.any(
              (cloudKnife) => (
              cloudKnife.id == localStatItem.id
                  && localStatItem.timestamp <= cloudKnife.timestamp
          )
      );
      if (!existsInCloud) {
        await StatisticCloudStorage().updateStatItem(localStatItem);
      }
    }

    for (var cloudStatItem in cloudStatItems) {
      bool existsLocally = localStatItems.any(
              (localKnife) => (
              localKnife.id == cloudStatItem.id
                  && localKnife.timestamp >= cloudStatItem.timestamp
          )
      );
      if (!existsLocally) {
        await StatisticLocalStorage().updateStatItem(cloudStatItem);
      }
    }
  }


  Future<void> _syncImages() async {
    List<ImageDbRow> localImageDbRows = await ImageLocalStorage().getAllImageDbRows();
    List<ImageDbRow> cloudImageDbRows = await ImageCloudStorage().getAllImageDbRows();

    for (var localImageDbRow in localImageDbRows) {
      bool existsInCloud = cloudImageDbRows.any(
              (cloudImageDbRow) => (
                   cloudImageDbRow.id == localImageDbRow.id
                && localImageDbRow.timestamp <= cloudImageDbRow.timestamp
                && localImageDbRow.url != ""
                && cloudImageDbRow.url != ""
        )
      );
      if (!existsInCloud) {
        await ImageCloudStorage().editImage(localImageDbRow);
      }
    }

    for (var cloudImageDbRow in cloudImageDbRows) {
      bool existsLocally = localImageDbRows.any(
              (localImageDbRow) => (
              cloudImageDbRow.id == localImageDbRow.id
                  && localImageDbRow.timestamp >= cloudImageDbRow.timestamp
                  && localImageDbRow.url != ""
                  && cloudImageDbRow.url != ""
          )
      );
      if (!existsLocally) {
        await ImageLocalStorage().setImageFromCloud(cloudImageDbRow);
      }
    }
  }
}