import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id;
  String name;
  String email;
  String requester;
  String status;
  List<Map<String, dynamic>> users = List<Map<String, dynamic>>();
  String userId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Group(this.id, this.name, this.userId, this.users, this.email);

  @override
  String toString() {
    return 'Group{name: $name, emails: $users}';
  }

  Group.fromDocument(DocumentSnapshot document) {
    name = document['name'] as String;
    id = document['groupId'] as String;
    email = document['email'] as String;
    requester = document['requester'] as String;
    users = [];
  }

  Group.fromDocumentToAdminView(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] as String;
    userId = document['userId'] as String;
    users = toMap(document["users"]);
  }

  List<Map<String, dynamic>> toMap(dynamic data) {
    List<Map<String, dynamic>> list = new List<Map<String, dynamic>>();
    for (var item in data) {
      final Map<String, dynamic> data = {
        'userName': item["userName"],
        'email': item["email"],
        'status': item["status"],
        'requester': item["requester"],
        'name_requester': item["name_requester"],
        'type': item["type"],
      };
      if (item["userId"] != null) {
        data["userId"] = item["userId"];
      }
      list.add(data);
    }
    return list;
  }

  Future<void> save() async {
    final Map<String, dynamic> data = {
      'name': name,
      'userId': userId,
      "users": users,
    };
    print("data salva $data");
    return data;
  }
}
