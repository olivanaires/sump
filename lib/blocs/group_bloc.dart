import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/model/group.dart';
import 'package:sumpapp/model/status.dart';
import 'package:sumpapp/model/user_model.dart';
import 'package:sumpapp/widgets/custom_dropdown.dart';

class GroupBloc implements BlocBase {
  DocumentSnapshot lastVisible;

  @override
  void dispose() {}

  void createGroup(Group group) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(group.userId).get();
    UserModel currentUser = UserModel.fromDocument(doc);

    final Map<String, dynamic> data = {
      'name': group.name,
      'userId': group.userId,
      'users': group.users,
    };

    if (group.id == null) {
      data['users'].add({
        'userId': currentUser.uid,
        'userName': currentUser.name,
        'email': currentUser.email,
        'type': 'ADMIN',
        'status': STATUS.APPROVED,
      });

      final Map<String, dynamic> userData = {};
      userData["userId"] = group.userId;
      userData["email"] = group.email;
      userData["name"] = group.name;
      userData["status"] = STATUS.APPROVED;
      userData["requester"] = group.email;
      await FirebaseFirestore.instance.collection('groups').add(data).then((value) async {
        userData["groupId"] = value.id;
        await FirebaseFirestore.instance.collection('users').doc(group.userId).collection("groups").add(userData);
      });
    } else {
      await FirebaseFirestore.instance.collection('groups').doc(group.id).set(data);
    }
  }

  void leaveGroup(Group group, String userUid) async {
    var query = await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('groups')
        .where(FieldPath.documentId, isEqualTo: group.id)
        .get();
    var userGroupId = query.docs.first.id;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('groups').doc(userGroupId).delete();

    group.users.removeWhere((user) => user['userId'] == userUid);
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(group.id).update({'users': group.users});
  }

  Stream<QuerySnapshot> loadInvitationsUsers(userId) {
    Stream<QuerySnapshot> snapshot =
        FirebaseFirestore.instance.collection('groups').where("userId", isEqualTo: userId).snapshots();
    return snapshot;
  }

  // Stream<QuerySnapshot> loadGroups(groupId) {
  //   Stream<DocumentSnapshot> snapshot = FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots();
  //   return snapshot;
  // }

  Stream<QuerySnapshot> loadGroupUsers(userId) {
    Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("groups")
        .where("status", isEqualTo: STATUS.APPROVED)
        .snapshots();
    return snapshot;
  }

  void removeUserInGroups(Group group, index) async {
    if (group.id != null) {
      Map<String, dynamic> dataUser = group.users[index];
      await FirebaseFirestore.instance.collection('groups').doc(group.id).update(({
            "users": FieldValue.arrayRemove([dataUser]),
          }));
      switch (dataUser["status"]) {
        case STATUS.INVITATION:
          QuerySnapshot query = await FirebaseFirestore.instance
              .collection('invitations')
              .where("email", isEqualTo: dataUser["email"])
              .get();
          await FirebaseFirestore.instance.collection('invitations').doc(query.docs.first.id).delete();
          break;
        case STATUS.APPROVED:
          await FirebaseFirestore.instance
              .collection('users')
              .doc(dataUser["userId"])
              .collection("groups")
              .doc(group.id)
              .delete();
          break;
        case STATUS.AWAITING:
          await FirebaseFirestore.instance
              .collection('users')
              .doc(dataUser["userId"])
              .collection("groups")
              .doc(group.id)
              .delete();
          break;
        default:
      }
    }
  }

  StreamBuilder<QuerySnapshot> dropDownGroupList(TextEditingController controller, userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: loadGroupUsers(userId),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return CustomDropdown(
            controller: controller,
            label: 'Grupo',
            items: snapshot.data.docs.map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem(
                child: Text('${e.data()['name']}'),
                value: e.get('groupId'),
              );
            }).toList(),
          );
        else
          return Container();
      },
    );
  }
}
