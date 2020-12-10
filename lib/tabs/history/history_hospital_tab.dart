import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/favorite_hospital_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/hospital_model.dart';

class HistoryHospitalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);
    final _favhospital = BlocProvider.of<FavoritHospitalBloc>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctorCalls')
          .where('requestor.uid', isEqualTo: _userBloc.firebaseUser.uid)
          .where('date', isLessThan: DateTime.now())
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {
          var hospitalsUid = snapshot.data.docs.map((dc) => dc['hospital']['uid']).toList();
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('hospitals')
                .where(FieldPath.documentId, whereIn: hospitalsUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.docs != null) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    var hospitalModel = HospitalModel.fromDocSnapshot(snapshot.data.docs[index]);
                    return InkWell(
                      onTap: () {
//                        Navigator.of(context).push(MaterialPageRoute(
//                            builder: (context) =>
//                                HospitalReviewsPage(hospitalUid: hospitalModel.uid, hospitalName: hospitalModel.name)));
                      },
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('Local: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                        Expanded(
                                          child: Text(
                                            '${hospitalModel?.name}',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                        StreamBuilder<List<String>>(
                                            stream: _favhospital.outFav,
                                            builder: (context, snapshot) {
                                              var icon = snapshot.hasData && snapshot.data.contains(hospitalModel?.uid)
                                                  ? Icons.star
                                                  : Icons.star_border;
                                              return GestureDetector(
                                                child: Icon(icon),
                                                onTap: () {
                                                  _favhospital.toggleHospital(
                                                      _userBloc.firebaseUser?.uid, hospitalModel?.uid);
                                                },
                                              );
                                            }),
                                        Padding(padding: EdgeInsets.only(right: 24.0)),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Text('Cidade: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${hospitalModel?.city}',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                        Text('Estado: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${hospitalModel?.state}',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
//                              Icon(Icons.keyboard_arrow_right)
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else
                return Container();
            },
          );
        } else
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor),
              Text('Carregando...'),
            ],
          );
      },
    );
  }
}
