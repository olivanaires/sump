import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/doctor_call_model.dart';
import 'package:sumpapp/tiles/doctor_call/doctor_call_tile.dart';

class MyCallTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctorCalls')
          .where('requestor.uid', isEqualTo: userBloc.firebaseUser.uid)
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return ListView.builder(
            itemCount: snapshot.data.docs.length + 1,
            itemBuilder: (context, index) {
              if (index < snapshot.data.docs.length) {
                return DoctorCallTile(DoctorCallModel.fromDocSnapshot(snapshot.data.docs[index]));
              } else {
                return Container();
              }
            },
          );
        else
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor),
                Text('Carregando...'),
              ],
            ),
          );
      },
    );
  }
}
