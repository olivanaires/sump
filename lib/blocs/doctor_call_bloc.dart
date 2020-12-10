import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class DoctorCallBloc implements BlocBase {
  Query defaultQuery;
  Query currentQuery;
  Map<String, dynamic> currentFilters = Map<String, dynamic>();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _loading = BehaviorSubject<bool>(seedValue: false);

  Stream<bool> get loading => _loading.stream;

  final _query = BehaviorSubject<Query>();

  Stream<Query> get query => _query.stream;

  DoctorCallBloc() {
    currentFilters = Map<String, dynamic>();
  }

  @override
  void dispose() {
    _loading.close();
    _query.close();
  }

  Future<Null> saveCall(Map<String, dynamic> docCall) async {
    _loading.sink.add(true);

    try {
      final docUser = await firestore.collection('users').doc('${docCall['owner']['uid']}').get();
      docCall['owner']['name'] = docUser.data()['name'];

      final docHospital = await firestore.collection('hospitals').doc('${docCall['hospital']['uid']}').get();
      docCall['hospital']['name'] = docHospital.data()['name'];
      docCall['hospital']['state'] = docHospital.data()['state'];
      docCall['hospital']['city'] = docHospital.data()['city'];

//      if (docCall['group'] != null) {
//        final docGroup = await firestore.collection('groups').doc('${docCall['group']['uid']}').get();
//        docCall['group']['name'] = docGroup.data()['name'];
//      }

      print(docCall);

      final refDoctorCallSerial = firestore.doc('aux/doctorCallSerial');
      firestore.runTransaction((tx) async {
        final docDoctorCallSerial = await tx.get(refDoctorCallSerial);
        final orderId = docDoctorCallSerial.data()['current'] as int;
        tx.update(refDoctorCallSerial, {'current': orderId + 1});

        var refDoctorCall = firestore.doc('doctorCalls/$orderId');
        tx.set(refDoctorCall, docCall);
      });
      _loading.sink.add(false);
    } catch (error) {
      debugPrint(error);
      _loading.sink.add(false);
    }
  }

  void requestCancelDoctorCall(
      Map<String, dynamic> values, VoidCallback onSuccess(isSolicitation), VoidCallback onFail) async {
    try {
      DocumentSnapshot requestor = await firestore.collection('users').doc(values['requestorUid']).get();

      DocumentSnapshot snapshot = await firestore.collection('doctorCalls').doc(values['doctorCallUid']).get();

      var isSolicitatio = snapshot['available'];

      var newValues = {
        'requestDate': DateTime.now(),
        'requestor': isSolicitatio
            ? {
                'uid': requestor.id,
                'name': requestor.data()['name'],
                'crm': requestor.data()['crm'],
              }
            : null,
        'available': !snapshot['available'],
      };

      await firestore.collection('doctorCalls').doc(values['doctorCallUid']).update(newValues);

      onSuccess(snapshot['available']);
    } catch (error) {
      onFail();
    }
  }

  var limit;

  Stream<QuerySnapshot> doctorCallBoard(Query query) {
    if (query == null) return Stream.empty();
    return query.snapshots();
  }

  void initializeBoardQuery(String doctorUid, bool group) async {
    limit = 20;
    if (group) {
      QuerySnapshot groups = await firestore.collection('users').doc(doctorUid).collection('groups').get();
      if (groups == null || groups.docs.length == 0) {
        _query.sink.add(null);
        return;
      }

      var groupsUid = groups.docs.map((e) => e.get('groupId')).toList();
      defaultQuery = firestore
          .collection('doctorCalls')
          .where('available', isEqualTo: true)
          .where('group', arrayContainsAny: groupsUid);
      currentQuery = defaultQuery.orderBy('date');
    } else {
      defaultQuery = firestore
          .collection('doctorCalls')
          .where('available', isEqualTo: true)
          .where('date', isGreaterThanOrEqualTo: DateTime.now());
      currentQuery = defaultQuery.where('group', isNull: true).orderBy('date');
    }

    _query.sink.add(currentQuery.limit(limit));
  }

  void nextPage(int qtd) async {
    if (limit < qtd) {
      limit = qtd;
      _query.sink.add(currentQuery.limit(limit));
    }
  }

  void updateQuery() {
    currentQuery = defaultQuery;
    if (currentFilters.containsKey('date') && currentFilters['date'].toString().isNotEmpty) {
      var date = DateFormat('dd/MM/yyyy HH:mm:ss').parse('${currentFilters['date']} 00:00:00');
      currentQuery = currentQuery.where('date', isGreaterThanOrEqualTo: date).orderBy('date');
    } else if (currentFilters.containsKey('value') && currentFilters['value'].toString().isNotEmpty) {
      var value = currentFilters['value'].replaceFirst(r'R$', '').trim().replaceAll(r'.', r'').replaceAll(r',', r'.');
      currentQuery = currentQuery
          .where('value', isGreaterThanOrEqualTo: double.tryParse(value))
          .orderBy('value', descending: true);
    } else {
      currentQuery.orderBy('date');
    }

    if (currentFilters.containsKey('group') && currentFilters['group'].isNotEmpty) {
      currentQuery.parameters['where'][1][2] = [currentFilters['group']];
//    } else {
//      currentQuery = currentQuery.where('group', isNull: true);
    }

    if (currentFilters.containsKey('scale') && currentFilters['scale'].toString().isNotEmpty) {
      currentQuery = currentQuery.where('scale', isEqualTo: int.tryParse(currentFilters['scale']));
    }

    if (currentFilters.containsKey('state') && currentFilters['state'].toString().isNotEmpty) {
      currentQuery = currentQuery.where('hospital.state', isEqualTo: currentFilters['state']);
    }

    if (currentFilters.containsKey('hospital') && currentFilters['hospital'].toString().isNotEmpty) {
      currentQuery = currentQuery.where('hospital.uid', isEqualTo: currentFilters['hospital']);
    }

    _query.sink.add(currentQuery);
  }

  void gera() async {
    QuerySnapshot snapshot = await firestore.collection('hospitals').get();
    List<DocumentSnapshot> hospitals = snapshot.docs;

    QuerySnapshot userssnapshot = await firestore.collection('users').get();
    List<DocumentSnapshot> users = userssnapshot.docs;

    for (int i = 1; i <= 20; i++) {
      var hospital = hospitals[0].data;
      hospital()['uid'] = hospitals[0].id;

      var user;
      user = {'uid': users[1].id, 'name': users[1].data()['name']};
      var uid = i < 10 ? '0$i' : '$i';
      await firestore.collection('doctorCalls').doc(uid).set({
        'available': true,
        'date': DateTime.now().add(Duration(days: i)),
        'hospital': hospital,
        'owner': user,
        'scale': i % 2 == 0 ? 12 : 24,
        'value': i
      });
    }
  }
}
