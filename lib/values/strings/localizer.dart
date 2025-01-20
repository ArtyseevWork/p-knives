import 'dart:ui';
import 'package:pknives/values/strings/uk.dart';
import 'package:pknives/values/strings/ru.dart';
import 'en.dart';

class Localizer {
  static late Map<String, String> _strings;
  static late Map<String, String> _en;
  static late Map<String, String> _ru;
  static late Map<String, String> _uk;

  static void init() {
    String code = 'en';
    Locale deviceLocale = window.locale;
    String languageCode = deviceLocale.languageCode;
    if (languageCode == 'ru' || languageCode == 'uk'){
      code = languageCode;
    }

    _en = English().get();
    switch (code) {
      case "uk":
        _strings = Ukraine().get();
      case "ru":
        _strings = Russian().get();
      default:
        _strings = _en;
    }
  }

  static String get(String key) {
    try{
      return _strings[key] ?? getEn(key);
    } catch(e){
      return key;
    }
  }

  static String getEn(String key) {
    return _en[key] ?? key;
  }
}