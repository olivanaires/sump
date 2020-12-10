import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/group_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/group.dart';
import 'package:sumpapp/screens/group/form.dart';

class MyGroupTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _useBloc = BlocProviderList.of<UserBloc>(context);
    final _group = BlocProviderList.of<GroupBloc>(context);
    // CollectionReference groups = FirebaseFirestore.instance.collection('groups');
    return StreamBuilder<QuerySnapshot>(
      stream: _group.loadGroupUsers(_useBloc.firebaseUser.uid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            Group group = Group.fromDocument(document);
            return CreateCard(group);
          }).toList(),
        );
      },
    );
  }
}

class CreateCard extends StatelessWidget {
  final Group _group;
  CreateCard(this._group);

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    return InkWell(
      onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return FormRegisterGroups(_group.id);
          }));
      },
      child: Card(
        child: ListTile(
          title: Text(_group.name),
        ),
      ),
    );
  }
}
