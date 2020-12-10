import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sumpapp/model/hospital_model.dart';

class DoctorCallModel {

  String uid;
  DateTime date;
  DateTime payDate;
  String ownerUid;
  String ownerName;
  int scale;
  double value;
  bool available;
  HospitalModel hospital;
  String requestorUid;
  

  DoctorCallModel.fromDocSnapshot(DocumentSnapshot doc) {
    uid = doc.id;
    available = doc['available'];
    date = (doc['date'] as Timestamp).toDate();
    payDate = (doc['payDate'] as Timestamp).toDate();
    scale = int.tryParse(doc['scale'].toString());
    value = double.tryParse(doc['value'].toString());
    hospital = HospitalModel.fromMap(doc['hospital']);
    ownerUid = doc['owner']['uid'];
    ownerName = doc['owner']['name'];
    requestorUid = doc.data().containsKey('requestor') ? doc['requestor']['uid'] : null;
  }

  @override
  String toString() {
    return 'DoctorCallModel{uid: $uid, date: $date, ownerUid: $ownerUid, value: $value}';
  }

}