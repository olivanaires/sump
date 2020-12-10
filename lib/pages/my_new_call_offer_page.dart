import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:sumpapp/blocs/doctor_call_bloc.dart';
import 'package:sumpapp/blocs/hospital_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/helpers/currency_input_formatter.dart';
import 'package:sumpapp/model/status.dart';
import 'package:sumpapp/widgets/custom_date_time.dart';
import 'package:sumpapp/widgets/custom_dropdown.dart';

class MyNewCallOfferPage extends StatelessWidget {
  final _hospitalController = TextEditingController();
  final _scaleController = TextEditingController();
  final _valueController = TextEditingController();
  final _payDateController = TextEditingController();
  final _dateController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    DateFormat _docCallDate = DateFormat("dd/MM/yyyy HH'h'");
    DateFormat _docCallPayDate = DateFormat("dd/MM/yyyy");
    final _userBloc = BlocProviderList.of<UserBloc>(context);
    final _hospitalBloc = BlocProviderList.of<HospitalBloc>(context);
    final _doctorCallBloc = BlocProviderList.of<DoctorCallBloc>(context);

    List _myGroups;

    return ScaffoldMessenger(
      key: _scaffoldMessageKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 90.0,
          title: Text(
            'Cadastrar Repasse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: StreamBuilder<bool>(
            stream: _doctorCallBloc.loading,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.data)
                return Form(
                  child: Column(
                    children: <Widget>[
                      _hospitalBloc.dropDownHospitalList(_hospitalController),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _valueController,
                              decoration: InputDecoration(hintText: 'Valor', labelText: 'Valor'),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            flex: 1,
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('aux').doc('scales').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data?.data()['options'] != null) {
                                  var options = snapshot.data.data()['options'];
                                  options.removeAt(0);
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
                          ),
                        ],
                      ),
                      CustomDateTime(_dateController, "Data/Hora do Plantão"),
                      TextFormField(
                        controller: _payDateController,
                        decoration: InputDecoration(
                          labelText: "Data Pagamento",
                          hintText: "Data Pagamento",
                        ),
                        onTap: () async {
                          var initialDate = _payDateController.text.isNotEmpty
                              ? DateFormat('dd/MM/yyyy').parse(_payDateController.text)
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
                            _payDateController.text =
                                _docCallPayDate.format(DateTime(picked.year, picked.month, picked.day));
                          }
                        },
                      ),
//                    _groupBloc.dropDownGroupList(_groupController, _userBloc.firebaseUser.uid),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(_userBloc.firebaseUser.uid)
                              .collection("groups")
                              .where("status", isEqualTo: STATUS.APPROVED)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            return MultiSelectFormField(
                              autovalidate: false,
                              chipBackGroundColor: Theme.of(context).primaryColor,
                              chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                              dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
                              checkBoxActiveColor: Theme.of(context).primaryColor,
                              checkBoxCheckColor: Theme.of(context).accentColor,
                              dialogShapeBorder:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                              title: Text("Grupos", style: TextStyle(fontSize: 16.0)),
//                            validator: (value) {
//                              if (value == null || value.length == 0) {
//                                return 'Selecione um grupo';
//                              }
//                              return null;
//                            },
                              dataSource: snapshot.data.docs,
                              textField: 'name',
                              valueField: 'groupId',
                              okButtonLabel: 'OK',
                              cancelButtonLabel: 'CANCEL',
                              hintWidget: Text('Grupos'),
                              initialValue: _myGroups,
                              onSaved: (value) {
                                if (value == null) return;
                                _myGroups = value;
                              },
                            );
                          }),
                      SizedBox(height: 36.0),
                      SizedBox(
                        height: 44.0,
                        child: RaisedButton(
                          child: Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).accentColor,
                          onPressed: () {
                            var value = _valueController.text
                                .replaceFirst(r'R$', '')
                                .trim()
                                .replaceAll(r'.', r'')
                                .replaceAll(r',', r'.');
                            var docCall = {
                              'available': true,
                              'date': _docCallDate.parse(_dateController.text),
                              'payDate': _docCallPayDate.parse(_payDateController.text),
                              'scale': int.tryParse(_scaleController.text),
                              'value': double.tryParse(value),
                              'owner': {'uid': _userBloc.firebaseUser.uid},
                              'hospital': {'uid': _hospitalController.text},
                              'group': _myGroups != null ?  _myGroups : null
                            };

                            _doctorCallBloc.saveCall(docCall);

                            _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
                              content: Text('Plantão cadastrado com sucesso'),
                              backgroundColor: Theme.of(context).primaryColor,
                              duration: Duration(seconds: 2),
                            ));

                            Future.delayed(Duration(seconds: 2)).then((_) {
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              else
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor),
                      Text('Registrando...'),
                    ],
                  ),
                );
            },
          ),
        ),
      ),
    );
  }
}
