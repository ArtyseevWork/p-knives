import 'package:cloud_firestore/cloud_firestore.dart';

class StatItem {
  int id;
  int knifeId;
  int angle;
  int date;
  int timestamp;

  StatItem(this.id, this.knifeId, this.angle, this.date, this.timestamp);

  StatItem.fromMap(Map<String, dynamic> row)
      : id        = row['_id'] ?? 0,
        knifeId   = row['knife_id'] ?? 0,
        angle     = row['angle'] ?? 0,
        date      = row['date'] ?? 0,
        timestamp = row['timestamp'] ?? 0;



  Map<String, dynamic> toMap() {
    if (id == 0){
      return {
        'knife_id': knifeId,
        'angle': angle,
        'date' : date,
        'timestamp' : timestamp
      };
    } else {
      return {
        '_id' : id,
        'knife_id': knifeId,
        'angle': angle,
        'date': date,
        'timestamp' : timestamp
      };
    }
  }

  StatItem.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.data()['_id'] ?? 0,
        knifeId = doc.data()['knife_id'] ?? "",
        angle = doc.data()['angle'] ?? 0,
        date = doc.data()['date'] ?? 0,
        timestamp = doc.data()['timestamp'] ?? 0;
}