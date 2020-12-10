import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'custom_dropdown.dart';

class CustomDateTime extends StatelessWidget {

  final String label;
  final TextEditingController _dateController;
  final _hourController = TextEditingController();

  CustomDateTime(this._dateController, this.label);

  @override
  Widget build(BuildContext context) {
    DateFormat _docCallDate = DateFormat("dd/MM/yyyy HH'h'");

    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: this.label,
        hintText: this.label,
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
          showDialog(
            context: context,
            builder: (_) => new AlertDialog(
              titlePadding: EdgeInsets.all(0),
              contentPadding: EdgeInsets.all(16.0),
              title: Container(
                padding: EdgeInsets.all(16.0),
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: new Text(
                    'Selecionar Hora',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
              content: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('aux').doc('hours').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data?.data()['options'] != null) {
                      var options = snapshot.data.data()['options'];
                      return CustomDropdown(
                        controller: _hourController,
                        label: 'Hora',
                        items: <String>[...options].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      );
                    } else
                      return Container();
                  }),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _dateController.text = _docCallDate.format(DateTime(
                        picked.year, picked.month, picked.day, int.tryParse(_hourController.text)));
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
