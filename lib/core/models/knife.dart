import 'package:pknives/core/models/statItem.dart';
import 'package:pknives/data/repo/image_repo.dart';
import 'package:pknives/data/repo/statistic_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Knife{
  int id;
  String name;
  String description;
  int angle;
  int status;
  static const String EXTRA_ID  = "EXTRA_KNIFE_ID";
  bool doubleSideSharp;
  int timestamp;
  String image = "";
  List<StatItem> statistic = [];

  Knife(
    this.id,
    this.name,
    this.description,
    this.angle,
    this.status,
    this.doubleSideSharp,
    this.timestamp,
  );

  Knife.fromMap2(Map<String, dynamic> row)
      : id = row['_id'] ?? 0,
        name = row['name'] ?? "",
        description = row['description'] ?? '',
        angle = row['angle'] ?? 0,
        status = row['status'] ?? 0,
        doubleSideSharp = row['double_side_sharpening']==1,
        timestamp = row['timestamp'] ?? 0;

  static Future<Knife> fromMapAsync(Map<String, dynamic> row) async {
    Knife result =  Knife(
      row['_id'] ?? 0,
      row['name'] ?? "",
      row['description'] ?? '',
      row['angle'] ?? 0,
      row['status'] ?? 0,
      row['double_side_sharpening'] == 1,
      row['timestamp'] ?? 0,
    );

    result.image = await ImageRepo().getImageByKnifeId(result.id);
    result.statistic = await StatisticRepo().getAllStatisticByKnifeId(result.id);

    return result;
  }



  Map<String, dynamic> toMap() {
    if (id == 0){
      return {
        'name': name,
        'description': description,
        'angle': angle,
        'status': status,
        'double_side_sharpening': doubleSideSharp ? 1 : 0,
        'timestamp' : timestamp
      };
    } else {
      return {
        '_id' : id,
        'name': name,
        'description': description,
        'angle': angle,
        'status': status,
        'double_side_sharpening': doubleSideSharp ? 1 : 0,
        'timestamp' : timestamp
      };
    }

  }

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;

    return other is Knife &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.angle == angle &&
        other.status == status &&
        other.doubleSideSharp == doubleSideSharp &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    description.hashCode ^
    angle.hashCode ^
    status.hashCode ^
    doubleSideSharp.hashCode ^
    timestamp.hashCode;
  }

  Knife.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.data()['_id'] ?? 0,
        name = doc.data()['name'] ?? "",
        description = doc.data()['description'] ?? '',
        angle = doc.data()['angle'] ?? 0,
        status = doc.data()['status'] ?? 0,
        doubleSideSharp = doc.data()['double_side_sharpening'] == 1,
        timestamp = doc.data()['timestamp'] ?? 0;



  static Knife getDefaultKnife(){
    return Knife(0, "Knife", "description", 45, 7, true, 0);
  }
}