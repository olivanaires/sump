import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/model/group.dart';
import 'package:sumpapp/tiles/group_list_form_tile.dart';

class FormRegisterGroups extends StatefulWidget {
  final String id;

  FormRegisterGroups(this.id);
  _FormGroupState createState() => _FormGroupState();
}

class _FormGroupState extends State<FormRegisterGroups> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    if (widget.id != null)
      return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('groups').doc(widget.id).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Group _group = Group.fromDocumentToAdminView(snapshot.data);
              return GroupListFormTile(_group, _scaffoldKey);
            } else {
              return Container();
            }
          });
    else
      return GroupListFormTile(new Group(null, null, "", [], ""), _scaffoldKey);
  }
}
