import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sumpapp/blocs/doctor_call_bloc.dart';
import 'package:sumpapp/blocs/group_bloc.dart';
import 'package:sumpapp/blocs/hospital_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/helpers/bloc_helper.dart';
import 'package:sumpapp/helpers/currency_input_formatter.dart';
import 'package:sumpapp/widgets/custom_dropdown.dart';

class DoctorCallFilterTile extends StatefulWidget {
  @override
  _DoctorCallFilterTileState createState() => _DoctorCallFilterTileState();
}

class _DoctorCallFilterTileState extends State<DoctorCallFilterTile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  final _dateController = TextEditingController();
  final _valueController = TextEditingController();
  final _scaleController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _stateController = TextEditingController();
  final _groupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _doctorCallBloc = BlocProviderList.of<DoctorCallBloc>(context);
    final _hospitalBloc = BlocProviderList.of<HospitalBloc>(context);
    final _groupBloc = BlocProviderList.of<GroupBloc>(context);
    final _useBloc = BlocProviderList.of<UserBloc>(context);
    final _blocHelper = BlocProviderList.of<BlocHelper>(context);

    if (_doctorCallBloc.currentFilters == null) _doctorCallBloc.currentFilters = Map<String, dynamic>();
//    _dateController.text = _doctorCallBloc.currentFilters['date'];
//    _valueController.text = _doctorCallBloc.currentFilters['value'];
//    _scaleController.text = _doctorCallBloc.currentFilters['scale'];
//    _hospitalController.text = _doctorCallBloc.currentFilters['hospital'];
//    _stateController.text = _doctorCallBloc.currentFilters['state'];
//    _groupController.text = _doctorCallBloc.currentFilters['group'];

    return ScaffoldMessenger(
      key: _scaffoldMessageKey,
      child: Scaffold(
        key: _scaffoldKey,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Drawer(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 56.0, horizontal: 34.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filtros',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: "Data/Hora do Plantão",
                        hintText: "Data/Hora do Plantão",
                      ),
                      onTap: () async {
                        var initialDate = _dateController.text.isNotEmpty
                            ? DateFormat('dd/MM/yyyy').parse(_dateController.text)
                            : DateTime.now();

                        final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 120)),
                          initialEntryMode: DatePickerEntryMode.calendar,
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Theme.of(context).accentColor,
                                ),
                                dialogBackgroundColor: Theme.of(context).accentColor,
                              ),
                              child: child,
                            );
                          },
                        );

                        if (picked != null) {
//                        Navigator.of(context).pop();
                          _dateController.text = DateFormat("dd/MM/yyyy").format(
                              DateTime(picked.year, picked.month, picked.day));
                          if (_valueController.text != null && _valueController.text.isNotEmpty) {
                            _valueController.text = '';
                            _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
                              content: Text('Favor, filtrar por Data/Hora ou Valor Mínimo.'),
                              backgroundColor: Theme.of(context).primaryColor,
                              duration: Duration(seconds: 2),
                            ));
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: _valueController,
                      decoration: InputDecoration(hintText: 'Valor Mínimo', labelText: 'Valor Mínimo'),
                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (_dateController.text != null && _dateController.text.isNotEmpty) {
                          _dateController.text = '';
                          _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
                            content: Text('Favor, filtrar por Data/Hora ou Valor Mínimo.'),
                            backgroundColor: Theme.of(context).primaryColor,
                            duration: Duration(seconds: 2),
                          ));
                        }
                      },
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('aux').doc('scales').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data?.data()['options'] != null) {
                          var options = snapshot.data.data()['options'];
                          return CustomDropdown(
                            controller: _scaleController,
                            label: 'Escala',
                            items: <String>[...options].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          );
                        } else
                          return Container();
                      },
                    ),
                    _hospitalBloc.dropDownHospitalList(_hospitalController),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('aux').doc('states').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data?.data()['options'] != null) {
                          var options = snapshot.data.data()['options'];
                          return CustomDropdown(
                            controller: _stateController,
                            label: 'Estado',
                            items: <String>[...options].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          );
                        } else
                          return Container();
                      },
                    ),
                    StreamBuilder<int>(
                      initialData: 0,
                      stream: _blocHelper.selectedTab,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == 1) {
                          return _groupBloc.dropDownGroupList(_groupController, _useBloc.firebaseUser.uid);
                        } else
                          return Container();
                      },
                    ),
                    SizedBox(height: 34.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 36.0,
                          child: RaisedButton(
                            child: Text(
                              'Buscar',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            textColor: Theme.of(context).accentColor,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              _doctorCallBloc.currentFilters['date'] = _dateController.text;
                              _doctorCallBloc.currentFilters['value'] = _valueController.text;
                              _doctorCallBloc.currentFilters['scale'] = _scaleController.text;
                              _doctorCallBloc.currentFilters['hospital'] = _hospitalController.text;
                              _doctorCallBloc.currentFilters['state'] = _stateController.text;
                              _doctorCallBloc.currentFilters['group'] = _groupController.text;
                              _doctorCallBloc.updateQuery();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 36.0,
                          child: RaisedButton(
                            child: Text(
                              'Limpar',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            textColor: Theme.of(context).accentColor,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              _doctorCallBloc.currentFilters = Map<String, dynamic>();
                              _doctorCallBloc.updateQuery();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
