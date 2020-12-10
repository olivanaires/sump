import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sumpapp/model/hospital_model.dart';
import 'package:sumpapp/widgets/custom_dropdown.dart';

class HospitalBloc implements BlocBase {
  final _hospitalList = BehaviorSubject<HospitalModel>();

  @override
  void dispose() {
    _hospitalList.close();
  }

  StreamBuilder<QuerySnapshot> dropDownHospitalList(TextEditingController controller) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return CustomDropdown(
            controller: controller,
            label: 'Hospital',
            items: snapshot.data.docs.map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem(
                child: Text('${e.data()['name']} - ${e.data()['city']}/${e.data()['state']}'),
                value: e.id,
              );
            }).toList(),
          );
        else
          return Container();
      },
    );
  }
}
