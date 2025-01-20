
import 'package:pknives/core/mvvm/view_model.dart';
import 'package:pknives/screens/profile/profile_model.dart';

class ProfileViewModel extends ViewModel {

  final ProfileModel _model = ProfileModel();
  bool goToKnives = false;
  bool showLoader = false;

  Future<void> onLoad()  async{
    await _model.onLoad();
    notify();
  }

  Future<void> signInWithGoogle()  async{
    showLoader = true;
    notify();
    bool successSignIn = await _model.signInWithGoogle();
    if (successSignIn){
      await _model.sync();
      goToKnives = true;
    }
    showLoader = false;
    notify();
  }

  Future<void> signOut()  async{
    showLoader = true;
    notify();
    await _model.signOut();
    showLoader = false;
    notify();
  }

  Future<void> sync()  async{
    showLoader = true;
    notify();
    await _model.sync();
    showLoader = false;
    notify();
  }

  Future<void> deleteGoogleUser()  async{
    showLoader = true;
    notify();
    await _model.deleteGoogleUser();
    showLoader = false;
    notify();
  }

  get user => _model.user;

}