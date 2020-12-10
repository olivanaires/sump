import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalModel {
  String uid;
  String name;

  String street;
  String streetNumber;
  String neigborhood;
  String city;
  String state;
  String cep;

  HospitalModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    name = map['name'];

    street = map['street'];
    streetNumber = map['streetNumber'];
    neigborhood = map['neigborhood'];
    city = map['city'];
    state = map['state'];
    cep = map['cep'];
  }

  HospitalModel.fromDocSnapshot(DocumentSnapshot doc) {
    uid = doc.id;
    name = doc.data()['name'];
    street = doc.data()['street'];
    streetNumber = doc.data()['streetNumber'];
    neigborhood = doc.data()['neigborhood'];
    city = doc.data()['city'];
    state = doc.data()['state'];
    cep = doc.data()['cep'];
  }
}
