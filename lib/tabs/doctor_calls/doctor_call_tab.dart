import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/doctor_call_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/doctor_call_model.dart';
import 'package:sumpapp/tiles/doctor_call/doctor_call_tile.dart';

class DoctorCallTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _doctorCallBloc = BlocProviderList.of<DoctorCallBloc>(context);
    final _userBloc = BlocProviderList.of<UserBloc>(context);
    _doctorCallBloc.initializeBoardQuery(_userBloc.firebaseUser.uid, false);

    return StreamBuilder<Query>(
      stream: _doctorCallBloc.query,
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return StreamBuilder<QuerySnapshot>(
            stream: _doctorCallBloc.doctorCallBoard(snapshot.data),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index < snapshot.data.docs.length) {
                      var docCall = DoctorCallModel.fromDocSnapshot(snapshot.data.docs[index]);
                      return DoctorCallTile(docCall);
                    } else if (index > 1) {
                      _doctorCallBloc.nextPage(index + 20);
                      return Container();
                    } else {
                      return Container();
                    }
                  },
                );
              } else
                return Container();
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
