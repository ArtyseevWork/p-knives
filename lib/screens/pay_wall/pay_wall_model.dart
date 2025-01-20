import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:pknives/util/adapty_helper.dart';

class PayWallModel {
  bool finishDataLoad = false;
  final adapty = AdaptyHelper();
  void Function(AdaptyError)? onAdaptyErrorOccurred;
  void Function(Object)? onUnknownErrorOccurred;
  List<AdaptyPaywallProduct>? paywallProducts;
  int currentIndexOfProduct = 0;


  Future <void> onLoad() async{
    paywallProducts = adapty.examplePaywallProducts;
    await checkSubscriptionStatus();
    finishDataLoad = true;
  }


  Future<void> checkSubscriptionStatus() async {
    try {
      final profile = await Adapty().getProfile();
      if (profile.accessLevels['premium']?.isActive ?? false) {
        print('Подписка активна');
      } else {
        print('Подписка не активна');
      }
    } catch (error) {
      print('Ошибка получения статуса подписки: $error');
    }
  }

  Future<void> choseProduct(int index) async {
    currentIndexOfProduct = index;
  }

  Future<void> purchaseProduct() async {
    try {
       await adapty.purchaseProduct(paywallProducts![currentIndexOfProduct]);
    } catch (error) {
      print('Ошибка при совершении покупки: $error');
    }
  }

}