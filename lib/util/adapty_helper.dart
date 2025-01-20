import 'dart:async' show Future;
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:pknives/screens/pay_wall/purchase_observer.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/values/strings/localizer.dart';


class AdaptyHelper{

  static final AdaptyHelper _instance = AdaptyHelper._internal();

  AdaptyHelper._internal();

  factory AdaptyHelper() {
    return _instance;
  }

  Future<void> init() async {
    await _loadPaywall();
    await _loadProfile();
  }


  bool loading = false;
  String? _enteredCustomerUserId;
  bool productsWasLoaded = false;
  AdaptyProfile? adaptyProfile;
  final String examplePaywallId = 'main_screen_offer';
  AdaptyPaywall? examplePaywall;
  List<AdaptyPaywallProduct>? examplePaywallProducts;
  final observer = PurchasesObserver();
  DemoPaywallFetchPolicy _examplePaywallFetchPolicy = DemoPaywallFetchPolicy.reloadRevalidatingCacheData;


  Future<void> _loadPaywall() async { // !
    this.examplePaywall = null;
    this.examplePaywallProducts = null;

    final paywall = await observer.callGetPaywall(
      examplePaywallId,
      'en',
      _examplePaywallFetchPolicy.adaptyPolicy(),
    );

    this.examplePaywall = paywall;

    if (paywall == null) return;

    final products = await observer.callGetPaywallProducts(paywall);

    this.examplePaywallProducts = products;
    if (products != null && products.length > 0){
      productsWasLoaded = true;
      print ("productsWasLoaded = true;");
    } else {
      print ("productsWasLoaded = false;");
    }
  }

  Future<void> _loadProfile() async {
    final profile = await observer.callGetProfile();
    _setProfile(profile);
  }

  void _setProfile(AdaptyProfile? profile){
      if (profile != null) {
        this.adaptyProfile = profile;
        this.loading = false;
        if (profile.accessLevels['premium']?.isActive ?? false) {
          Options.isPremiumAccount = true;
        } else {
          Options.isPremiumAccount = false;
        }
      }
  }

  Future<void> purchaseProduct(AdaptyPaywallProduct product) async {
    final profile = await observer.callMakePurchase(product);
    _setProfile(profile);
  }

  static String getMonthPrice(AdaptyPaywallProduct product) {
    String result = "";
    int countOfMonths = 0;
    if (product.subscriptionDetails != null &&
        product.subscriptionDetails?.subscriptionPeriod != null &&
        product.subscriptionDetails?.subscriptionPeriod.unit.index == 3){
      countOfMonths = (product.subscriptionDetails!.subscriptionPeriod.numberOfUnits * 12);
    } else if(product.subscriptionDetails != null &&
        product.subscriptionDetails?.subscriptionPeriod != null &&
        product.subscriptionDetails?.subscriptionPeriod.unit.index == 2){
      countOfMonths = (product.subscriptionDetails!.subscriptionPeriod.numberOfUnits);
    } else {
      return result;
    }
    var fullPrice = product.price.amount;
    var monthsPrice = (fullPrice/countOfMonths).toStringAsFixed(2);
    String currencyName = extractCurrencyName(product.price.localizedString);
    result = "$monthsPrice $currencyName/${Localizer.get('paywall_month')}";
    return result;
  }


  static String extractCurrencyName(String? localizedString) {
    if (localizedString == null || localizedString.isEmpty) return "";
    final match = RegExp(r'[,.\d\s]+(\D+)$').firstMatch(localizedString);
    return match != null ? match.group(1)?.trim() ?? '' : '';
  }

}
enum DemoPaywallFetchPolicy {
  reloadRevalidatingCacheData,
  returnCacheDataElseLoad,
  returnCacheDataIfNotExpiredElseLoadMaxAge10sec,
  returnCacheDataIfNotExpiredElseLoadMaxAge30sec,
  returnCacheDataIfNotExpiredElseLoadMaxAge120sec,
}

extension DemoPaywallFetchPolicyExtension on DemoPaywallFetchPolicy {
  String title() {
    switch (this) {
      case DemoPaywallFetchPolicy.reloadRevalidatingCacheData:
        return "Reload Revalidating Cache Data";
      case DemoPaywallFetchPolicy.returnCacheDataElseLoad:
        return "Return Cache Data Else Load";
      case DemoPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoadMaxAge10sec:
        return "Cache Else Load (Max Age 10sec)";
      case DemoPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoadMaxAge30sec:
        return "Cache Else Load (Max Age 30sec)";
      case DemoPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoadMaxAge120sec:
        return "Cache Else Load (Max Age 120sec)";
    }
  }

  AdaptyPaywallFetchPolicy adaptyPolicy() {
    switch (this) {
      case DemoPaywallFetchPolicy.reloadRevalidatingCacheData:
        return AdaptyPaywallFetchPolicy.reloadRevalidatingCacheData;
      case DemoPaywallFetchPolicy.returnCacheDataElseLoad:
        return AdaptyPaywallFetchPolicy.returnCacheDataElseLoad;
      case DemoPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoadMaxAge10sec:
        return AdaptyPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoad(const Duration(seconds: 10));
      case DemoPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoadMaxAge30sec:
        return AdaptyPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoad(const Duration(seconds: 30));
      case DemoPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoadMaxAge120sec:
        return AdaptyPaywallFetchPolicy.returnCacheDataIfNotExpiredElseLoad(const Duration(seconds: 120));
    }
  }
}
