import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepo{

  Future<void> deleteGoogleUser() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Google User is null");
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reauthenticateWithCredential(credential);

        await deleteUserData(user.uid);
        await deleteUserImages(user.uid);

        await user.delete();
        print("User account and data deleted successfully.");
      }
      user = null;
    } catch (e) {
      print("Error during reauthentication or deleting user: $e");
    }
  }


  Future<void> deleteUserData(String userId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      await _deleteSubcollection(userDoc, 'images');
      await _deleteSubcollection(userDoc, 'knives');
      await _deleteSubcollection(userDoc, 'statItems');

      await userDoc.delete();

      print("User data and all subcollections deleted successfully.");
    } catch (e) {
      print("Error deleting user data: $e");
    }
  }

  Future<void> _deleteSubcollection(DocumentReference userDoc, String subcollectionName) async {
    try {
      final subcollection = userDoc.collection(subcollectionName);
      final documents = await subcollection.get();

      for (var doc in documents.docs) {
        await doc.reference.delete();
      }

      print("Subcollection '$subcollectionName' deleted.");
    } catch (e) {
      print("Error deleting subcollection '$subcollectionName': $e");
    }
  }

  Future<void> deleteUserImages(String userId) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference userImagesRef = storage.ref().child('images/$userId');
      final ListResult result = await userImagesRef.listAll();

      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }

      for (Reference dirRef in result.prefixes) {
        await _deleteDirectory(dirRef);
      }

      print("All images for user $userId deleted successfully.");
    } catch (e) {
      print("Error deleting user images: $e");
    }
  }

  Future<void> _deleteDirectory(Reference directoryRef) async {
    try {
      final ListResult result = await directoryRef.listAll();

      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }

      for (Reference dirRef in result.prefixes) {
        await _deleteDirectory(dirRef);
      }

      print("Deleted directory: ${directoryRef.fullPath}");
    } catch (e) {
      print("Error deleting directory: $e");
    }
  }


}

