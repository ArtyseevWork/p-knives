import 'package:pknives/core/models/knife.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KnifeCloudStorage{
  Future<void> updateKnife(Knife knife) async {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');
    final user = FirebaseAuth.instance.currentUser;
    final CollectionReference knives = users.doc(user?.uid).collection('knives');
    await knives.doc(knife.id.toString()).set(
      knife.toMap(),
    ).then((value) {
      //print('Data added with ID: ${value.id}');
      // You can navigate back to the previous screen or display a success message
    }).catchError((error) {
      // Error adding data
      print('Failed to add data: $error');
    });
  }


  Future<List<Knife>> getAllKnives() async {
    List<Knife> cloudKnives = [];
    final user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> cloudKnivesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid.toString())
        .collection('knives')
        .get();

    cloudKnives = cloudKnivesSnapshot.docs
        .map((doc) => Knife.fromFirestore(doc))
        .toList();
    return cloudKnives;
  }
}