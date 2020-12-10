import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sumpapp/blocs/favorite_hospital_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/helpers/currency_input_formatter.dart';
import 'package:sumpapp/model/doctor_call_model.dart';
import 'package:sumpapp/pages/doctor_call_page.dart';

class DoctorCallTile extends StatelessWidget {
  final DoctorCallModel doctorCallModel;

  DoctorCallTile(this.doctorCallModel);

  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);
    final _favhospital = BlocProvider.of<FavoritHospitalBloc>(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorCallPage(doctorCallModel.uid)));
      },
      child: Card(
        color: doctorCallModel.ownerUid == _userBloc.firebaseUser.uid ? Colors.lightBlue : Colors.white,
        margin: EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('Local: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                            child: Text(
                                '${doctorCallModel.hospital?.name} - ${doctorCallModel.hospital?.city}/${doctorCallModel.hospital?.state} ')),
                        StreamBuilder<List<String>>(
                            stream: _favhospital.outFav,
                            builder: (context, snapshot) {
                              var icon = snapshot.hasData && snapshot.data.contains(doctorCallModel.hospital?.uid)
                                  ? Icons.star
                                  : Icons.star_border;
                              if (doctorCallModel.ownerUid == _userBloc.firebaseUser.uid) return Container();

                              return GestureDetector(
                                child: Icon(icon),
                                onTap: () {
                                  _favhospital.toggleHospital(
                                      _userBloc.firebaseUser?.uid, doctorCallModel.hospital?.uid);
                                },
                              );
                            }),
                        Padding(padding: EdgeInsets.only(right: 24.0)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Data e Hora: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(DateFormat('dd/MM/yyyy HH:mm').format(doctorCallModel.date))),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Médico: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(doctorCallModel.ownerName)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Valor: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(CurrencyInputFormatter.valueFormatter(doctorCallModel.value)),
                        ),
                        Text('Escala: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${doctorCallModel.scale}'),
                        Padding(padding: EdgeInsets.only(right: 24.0)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right)
            ],
          ),
        ),
      ),
    );
  }
}
