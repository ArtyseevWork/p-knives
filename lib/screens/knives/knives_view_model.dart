
import '../../core/mvvm/view_model.dart';
import 'knives_model.dart';

class KnivesViewModel extends ViewModel {
  final KnivesModel _model = KnivesModel();
  bool showLoader = true;

  Future<void> onLoad()  async{
    await _model.onLoad();
    showLoader = false;
    notify();
  }

  Future<void> addTestData()  async{
    await _model.addTestData();
    notify();
  }

  Future<void> shareApp() async {
    await _model.shareApp();
  }

  get knives => _model.knives;
}