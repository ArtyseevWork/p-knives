import 'package:pknives/core/mvvm/view_model.dart';
import 'package:pknives/screens/pay_wall/pay_wall_model.dart';

class PayWallViewModel extends ViewModel {


  final PayWallModel _model = PayWallModel();

  Future<void> onLoad()  async{
    try{
      await _model.onLoad();
      notify();
    } catch(e){
      print (e);
    }
  }

  Future<void> choseProduct(index)  async{
    await _model.choseProduct(index);
    notify();
  }


  Future<void> purchaseProduct()  async{
    await _model.purchaseProduct();
    notify();
  }

  get paywallProducts => _model.paywallProducts;
  get finishDataLoad => _model.finishDataLoad;
  get currentIndexOfProduct => _model.currentIndexOfProduct;
}