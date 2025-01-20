import 'package:pknives/util/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelRepo{

  Future<double> getLevelValue() async {
    double levelValue = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
      levelValue =  prefs.getDouble(PreferencesKeys.levelValueStringKey) ?? 0;
    return levelValue;
  }

  Future<void> setLevelValue(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(PreferencesKeys.levelValueStringKey, value);
    prefs.setBool(PreferencesKeys.levelIsHoldStringKey, true);
  }

  Future<void> resetLevelValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(PreferencesKeys.levelValueStringKey, 0);
  }


  Future<bool> getLevelIsHold() async {
    bool result = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result =  prefs.getBool(PreferencesKeys.levelIsHoldStringKey) ?? false;
    return result;
  }

  Future<void> setLeveIsHold(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(PreferencesKeys.levelIsHoldStringKey, value);
  }
}