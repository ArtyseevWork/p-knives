import 'dart:async';

import 'package:pknives/core/models/axis.dart';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/data/repo/level_repo.dart';
import 'package:pknives/data/repo/statistic_repo.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/models/statItem.dart';
import 'dart:math' as math;

class SharpenModel {
  final double _alpha = 1;
  late Knife knife;
  double rotation = 0.0;
  double sensorDegree = 0.0;
  double levelDegree = 0;
  double displayDegree = 0;
  Axis currentAxis = Axis.x;
  bool orientationWasChanged = false;
  bool rightAngle = false;
  bool isHoldLevel = false;
  final double sensitivityThreshold = 0.5; // Порог изменения
  final AudioPlayer _audioPlayer = AudioPlayer();
  AccelerometerEvent? oldEvent;



  Future<void> onLoad(Knife knife) async {
    this.knife = knife;
    isHoldLevel = await LevelRepo().getLevelIsHold();
    if(isHoldLevel){
      levelDegree = await LevelRepo().getLevelValue();
    }
    print ("knife id = ${knife.id}");
  }

  bool shouldProcessEvent(
      AccelerometerEvent? event1,
      AccelerometerEvent? event2, {
        double threshold = 0.5,
        int frequencyHz = 30,
      }) {
    if(event1 == null || event2 == null) return true;

    int updateIntervalMs = (1000 / frequencyHz).round();
    int timeDifferenceMs = event2.timestamp.difference(event1.timestamp).inMilliseconds;

    if (timeDifferenceMs >= updateIntervalMs) {
      return (event1.x - event2.x).abs() > threshold ||
          (event1.y - event2.y).abs() > threshold ||
          (event1.z - event2.z).abs() > threshold;
    }

    return false;
  }

  bool processAxis(AccelerometerEvent event){

    if ( !shouldProcessEvent(event, oldEvent))  return false;

    if (getLandscapeOrientation(event) == DeviceOrientation.landscapeLeft){
      orientationWasChanged = true;
    } else if(getLandscapeOrientation(event) == DeviceOrientation.landscapeRight){
      orientationWasChanged = false;
    }

    switch (currentAxis) {
      case Axis.x:
        if (orientationWasChanged) {
          rotation = math.atan2(-event.y, -event.x) * (180 / math.pi);
        } else {
          rotation = math.atan2(event.y, event.x) * (180 / math.pi);
        }
        break;
      case Axis.y:
        if (orientationWasChanged) {
          rotation = math.atan2(-event.z, -event.y) * (180 / math.pi);
        } else {
          rotation = math.atan2(event.z, event.y) * (180 / math.pi);
        }
        break;
      case Axis.z:
        if (orientationWasChanged) {
          rotation = math.atan2(-event.x, -event.z) * (180 / math.pi);
        } else {
          rotation = math.atan2(event.x, event.z) * (180 / math.pi);
        }
        break;
    }
    _calculateDisplayDegree(rotation);
    return true;
  }



  Future <void> saveKnife(void Function() callback) async {
    addStatItem();
    callback();
  }

  Future <void> addStatItem() async{
    await StatisticRepo().updateStatItem(
      StatItem(
        0,
        knife.id,
        knife.angle,
        DateTime.now().millisecondsSinceEpoch,
        0,// ~/ 1000;,
      ));
  }

  void accelerometerListener(AccelerometerEvent event){
    // Вычисляем угол поворота на основе данных акселерометра
    rotation = math.atan2(event.y, event.x) * (180 / math.pi);
    _calculateDisplayDegree(rotation);
  }

  void _calculateDisplayDegree(double rotation) {
    sensorDegree = _alpha * rotation + (1 - _alpha) * sensorDegree;

    sensorDegree = _alpha * rotation + (1 - _alpha) * sensorDegree;
    displayDegree = (sensorDegree - levelDegree).abs() % 90;

    if (knife.doubleSideSharp && (knife.angle/ 2 - displayDegree).abs() < 0.5) {
      _playSound();
      rightAngle = true;
    } else if (!knife.doubleSideSharp &&
    (knife.angle - displayDegree).abs() < 0.5) {
      _playSound();
      rightAngle = true;
    } else {
      rightAngle = false;
    }
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  void changeAxis(){
    switch (currentAxis) {
      case Axis.x:
        currentAxis = Axis.y;
        break;
      case Axis.y:
        currentAxis = Axis.z;
        break;
      case Axis.z:
        currentAxis = Axis.x;
        break;
    }
  }

  void setLevel() {
    levelDegree = sensorDegree;
    if(isHoldLevel){
      LevelRepo().setLevelValue(levelDegree);
    }
    currentAxis = Axis.x;
  }

  void resetLevel() {
    levelDegree = 0;
    if(isHoldLevel){
      LevelRepo().setLevelValue(0);
    }
  }

  Future<bool> setHoldLevel() async{
    bool result = false;
    result = ! await LevelRepo().getLevelIsHold();
    LevelRepo().setLeveIsHold(result);
    isHoldLevel = result;
    return result;
  }

  DeviceOrientation getLandscapeOrientation(AccelerometerEvent event) {
    return event.x > 0 ? DeviceOrientation.landscapeRight
        : DeviceOrientation.landscapeLeft;
  }
}

enum DeviceOrientation {
  landscapeLeft,
  landscapeRight,
}
