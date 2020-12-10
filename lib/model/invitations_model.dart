import 'package:cloud_firestore/cloud_firestore.dart';

class Invitations {
  String id;
  String grouId;
  String name;
  String email;
  int status;
  String requester;
  String nameRequester;

  Invitations({this.id, this.email, this.status});

  Invitations.fromDocument(DocumentSnapshot document) {
    id = document.get("groupId");
    grouId = document.get("groupId");
    name = document.get('name');
    status = document.get('status');
    requester = document.get('requester');
    nameRequester = document.get('name_requester');
  }
}
