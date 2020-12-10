import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/doctor_call_model.dart';
import 'package:sumpapp/tiles/doctor_call/doctor_call_tile.dart';

class HistoryMyOfferDocCallTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctorCalls')
          .where('owner.uid', isEqualTo: _userBloc.firebaseUser.uid)
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor),
                Text('Carregando...'),
              ],
            );
          case ConnectionState.done:
          case ConnectionState.active:
            if (snapshot.data != null)
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  if (snapshot.data.docs.length > index) {
                    return DoctorCallTile(DoctorCallModel.fromDocSnapshot(snapshot.data.docs[index]));
                  } else
                    return Container();
                },
              );
            break;
          case ConnectionState.none:
            return Container();
        }
        return Container();
      },
    );
  }
}
