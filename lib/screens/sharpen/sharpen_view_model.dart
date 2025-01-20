
import 'package:pknives/screens/sharpen/sharpen_model.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/models/knife.dart';
import '../../core/mvvm/view_model.dart';
import '../../values/strings/localizer.dart';

class SharpenViewModel extends ViewModel {
  final SharpenModel _model = SharpenModel();
  String toastMessage = "";

  Future<void> onLoad(Knife knife)  async{
    _model.onLoad(knife);
    notify();
  }

  Future <void> saveKnife(void Function() callback) async {
    toastMessage = Localizer.get("activity_angle_toast_save_knife");
    await _model.saveKnife(callback);
  }

  void setLevel() async {
    _model.setLevel();
    toastMessage = Localizer.get("activity_angle_toast_set_level")
      + _model.levelDegree.toString();
    notify();
  }

  Future <void> setHoldLevel() async {
    await _model.setHoldLevel();
    if(_model.isHoldLevel){
      toastMessage = Localizer.get('activity_angle_toast_hold_level_true');
    } else {
      toastMessage = Localizer.get('activity_angle_toast_hold_level_false');
    }
    notify();
  }

  Future <void> resetLevel() async {
    _model.resetLevel();
    toastMessage = Localizer.get("activity_angle_toast_reset_level");
    notify();
  }

  void processAxis(AccelerometerEvent event) {
    if (_model.processAxis(event)) notify();
  }

  void changeAxis(){
    _model.changeAxis();
    toastMessage = Localizer.get("activity_angle_toast_current_axis")
        + _model.currentAxis.toString();
    notify();
  }

  Knife get knife => _model.knife;
  bool get orientationWasChanged => _model.orientationWasChanged;
  get rightAngle => _model.rightAngle;
  get levelDegree => _model.levelDegree;
  get displayDegree => _model.displayDegree;
  get sensorDegree => _model.sensorDegree;
  get isHoldLevel => _model.isHoldLevel;
  get currentAxis => _model.currentAxis;

}