import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pknives/core/models/enter_code.dart';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/data/repo/knife_repo.dart';
import 'package:pknives/data/storage/demo_data.dart';
import 'package:pknives/data/synchronization.dart';
import 'package:pknives/screens/pay_wall/purchase_observer.dart';
import 'package:pknives/values/strings/localizer.dart';
import 'adapty_helper.dart';
import 'app_settings.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      await _initializeLocalization();
      await _initializeFirebase();
      await _initializePurchases();
      await _initializeAdapty();
      await _initializeUser();
      await _startSync();
      await _checkDemoData();
    } catch (e, stackTrace) {
      print('Ошибка во время инициализации: $e\n$stackTrace');
    }
  }

  static Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch(e) {
      print(e.toString());
    }
  }

  static Future<void> _initializePurchases() async {
    try {
      PurchasesObserver().initialize();
    } catch(e) {
      print(e.toString());
    }
  }

  static Future<void> _initializeLocalization() async {
    try {
      Localizer.init();
    }catch(e) {
      print(e.toString());
    }
  }

  static Future<void> _initializeAdapty() async {
    try {
      await AdaptyHelper().init();
    } catch(e) {
      print(e.toString());
    }
  }

  static Future<void> _initializeUser() async {
    try{
      final user = FirebaseAuth.instance.currentUser;
      Options.syncEnable = user != null && Options.isPremiumAccount;
    } catch(e) {
      print(e.toString());
    }

  }

  static Future<void> _checkDemoData() async {
    try{
      List<Knife> allKnives = await KnifeRepo().getAllKnives();
      if (allKnives.isEmpty && await _isFirstEnter()) {
        await DemoData().addDemoData();
        await _setFirstEnter(EnterCode.ANOTHER_RUN);
      }
    } catch(e) {
      print(e.toString());
    }
  }

  static Future<void> _startSync() async {
    try {
      if (Options.syncEnable) await Synchronization().syncAll();
    } catch(e) {
      print(e.toString());
    }
  }

  static Future<bool> _isFirstEnter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int enterCode = prefs.getInt(PreferencesKeys.enterCodeStringKey) ?? EnterCode.FIRST_RUN;
    return enterCode == EnterCode.FIRST_RUN;
  }

  static Future<void> _setFirstEnter(int code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferencesKeys.enterCodeStringKey, code);
  }
}
