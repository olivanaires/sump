import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/doctor_call_model.dart';
import 'package:sumpapp/tiles/doctor_call/doctor_call_tile.dart';

class MyOfferCallTab extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessageKey;

  const MyOfferCallTab(this._scaffoldMessageKey);

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctorCalls')
          .where('owner.uid', isEqualTo: userBloc.firebaseUser.uid)
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length + 1,
            itemBuilder: (context, index) {
              if (index < snapshot.data.docs.length) {
                return Dismissible(
                  key: Key('${snapshot.data.docs[index].id}'),
                  background: Container(
                      padding: EdgeInsets.only(left: 320.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      color: Colors.red),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    var docUid = snapshot.data.docs[index].id;
                    await FirebaseFirestore.instance.collection('doctorCalls').doc(docUid).delete();

                    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
                      content: Text('Repasse removido com sucesso.'),
                      backgroundColor: Theme.of(context).primaryColor,
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: DoctorCallTile(
                    DoctorCallModel.fromDocSnapshot(snapshot.data.docs[index]),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        }

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
