import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;

  String name;
  String email;

  String profileImgURL;

  bool valid = false;

  UserModel();

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];

    name = map['name'];
    email = map['email'];

    profileImgURL = map['profileImgURL'];

    valid = map['valid'] ?? valid;
  }

  UserModel.fromDocument(DocumentSnapshot document) {
    name = document['name'] as String;
    uid = document.id;
    email = document['email'] as String;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImgURL': profileImgURL,
      'valid': valid,
    };
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, namme: $name, email: $email, valid: $valid)';
  }
}
