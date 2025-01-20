import 'package:pknives/data/repo/user_repo.dart';
import 'package:pknives/data/synchronization.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class ProfileModel {
  User? user = FirebaseAuth.instance.currentUser;


  Future <void> onLoad() async{
  }

  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =  await FirebaseAuth.instance.signInWithCredential(credential);
    user = FirebaseAuth.instance.currentUser;
    if (user != null){
      Options.syncEnable = true;
      return true;
    } else {
      return false;
    }
  }


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    user = null;
    Options.syncEnable = false;
  }

  Future<void> deleteGoogleUser() async {
    await UserRepo().deleteGoogleUser();
    user = null;
    Options.syncEnable = false;
  }

  Future<void> sync() async {
    if (Options.syncEnable){
      await Synchronization().syncAllAsync();
    }
  }

}