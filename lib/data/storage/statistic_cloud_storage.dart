import 'package:pknives/core/models/statItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticCloudStorage{
  Future<void> updateStatItem(StatItem statItem) async {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');
    final user = FirebaseAuth.instance.currentUser;
    final CollectionReference statItems = users.doc(user?.uid).collection('statItems');
    await statItems.doc(statItem.id.toString()).set(
      statItem.toMap(),
    ).then((value) {
      //print('Data added with ID: ${value.id}');
    }).catchError((error) {
      // Error adding data
      print('Failed to add data: $error');
    });
  }


  Future<List<StatItem>> getAllStatistic() async {
    List<StatItem> statItems = [];
    final user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> cloudKnivesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid.toString())
        .collection('statItems')
        .get();

    statItems = cloudKnivesSnapshot.docs
        .map((doc) => StatItem.fromFirestore(doc))
        .toList();
    return statItems;
  }
}
