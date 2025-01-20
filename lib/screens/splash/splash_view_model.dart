
import '../../core/mvvm/view_model.dart';
import 'splash_model.dart';

class SplashViewModel extends ViewModel {
  final SplashModel _model = SplashModel();
  bool finishTimer = false;

  Future<void> onLoad()  async{
    await _model.onLoad();
    notify();
  }

  bool get finishDataLoad => _model.finishDataLoad;
}