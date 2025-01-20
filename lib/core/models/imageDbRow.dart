import 'package:cloud_firestore/cloud_firestore.dart';

class ImageDbRow {
  int id;
  int knifeId;
  String name;
  String url;
  int timestamp;

  ImageDbRow(
    this.id,
    this.knifeId,
    this.name,
    this.url,
    this.timestamp
  );

  ImageDbRow.fromMap(Map<String, dynamic> row)
      : id        = row['_id'] ?? 0,
        knifeId   = row['knife_id'] ?? 0,
        name      = row['name'] ?? "",
        url       = row['url'] ?? "",
        timestamp = row['timestamp'] ?? 0;

  Map<String, dynamic> toMap() {
    if (id == 0){
      return {
        'knife_id': knifeId,
        'name' : name,
        'url' : url,
        'timestamp' : timestamp,
      };
    } else {
      return {
        '_id' : id,
        'knife_id': knifeId,
        'name' : name,
        'url' : url,
        'timestamp' : timestamp,
      };
    }
  }

  ImageDbRow.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.data()['_id'] ?? 0,
        knifeId = doc.data()['knife_id'] ?? "",
        name = doc.data()['name'] ?? "",
        url = doc.data()['url'] ?? "",
        timestamp = doc.data()['timestamp'] ?? 0;


}