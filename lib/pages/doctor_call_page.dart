import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sumpapp/blocs/doctor_call_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/helpers/currency_input_formatter.dart';
import 'package:sumpapp/model/doctor_call_model.dart';
import 'package:sumpapp/model/hospital_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorCallPage extends StatefulWidget {
  final String doctorCallUid;

  DoctorCallPage(this.doctorCallUid);

  @override
  _DoctorCallPageState createState() => _DoctorCallPageState(doctorCallUid);
}

class _DoctorCallPageState extends State<DoctorCallPage> {
  final String doctorCallUid;

  _DoctorCallPageState(this.doctorCallUid);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  List<Item> _data = [
    Item('Informações Plantão', isExpanded: true),
    Item('Outras Informações', isExpanded: false),
  ];

  @override
  Widget build(BuildContext context) {
    final doctorCallBloc = BlocProviderList.of<DoctorCallBloc>(context);
    final userBloc = BlocProviderList.of<UserBloc>(context);

    return ScaffoldMessenger(
      key: _scaffoldMessageKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 90.0,
          title: Text(
            'Repasse Nº $doctorCallUid',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('doctorCalls').doc(doctorCallUid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data.data != null) {
              var docCall = DoctorCallModel.fromDocSnapshot(snapshot.data);
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ExpansionPanelList(
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            _data[index].isExpanded = !isExpanded;
                          });
                        },
                        children: [
                          ExpansionPanel(
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return Container(
                                padding: EdgeInsets.only(left: 16.0, top: 8.0),
                                child: Text(
                                  _data[0].headerValue,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                                ),
                              );
                            },
                            body: Container(
                              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('hospitals')
                                    .doc(docCall.hospital.uid)
                                    .snapshots(),
                                builder: (context, snapshotHospital) {
                                  if (snapshotHospital.hasData) {
                                    var docHosp = HospitalModel.fromDocSnapshot(snapshotHospital.data);
                                    return Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text('Local: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                child: Text(
                                                  '${docHosp?.name}',
                                                  style: TextStyle(fontSize: 16.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              Text('Cidade: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                child: Text(
                                                  '${docHosp?.city}',
                                                  style: TextStyle(fontSize: 16.0),
                                                ),
                                              ),
                                              Text('Estado: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Text(
                                                '${docHosp?.state}',
                                                style: TextStyle(fontSize: 16.0),
                                              ),
                                              Padding(padding: EdgeInsets.only(right: 24.0)),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              Text('Lograd.: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                child: Text(
                                                  '${docHosp?.street ?? ""}',
                                                  style: TextStyle(fontSize: 16.0),
                                                ),
                                              ),
                                              Text('Nº: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Text(
                                                '${docHosp?.streetNumber ?? ""}',
                                                style: TextStyle(fontSize: 16.0),
                                              ),
                                              Padding(padding: EdgeInsets.only(right: 24.0)),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              Text('Bairro: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  '${docHosp?.neigborhood ?? ""}',
                                                  style: TextStyle(fontSize: 16.0),
                                                ),
                                              ),
                                              Text('CEP: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  '${docHosp?.cep ?? ""} ',
                                                  style: TextStyle(fontSize: 16.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              Text('Data e Hora: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                  child: Text(DateFormat('dd/MM/yyyy HH:mm').format(docCall.date),
                                                      style: TextStyle(fontSize: 16.0))),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              Text('Data Pagamento: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                  child: Text(DateFormat('dd/MM/yyyy').format(docCall.payDate),
                                                      style: TextStyle(fontSize: 16.0))),
                                              Text('Escala: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Text('${docCall.scale}', style: TextStyle(fontSize: 16.0)),
                                              Padding(padding: EdgeInsets.only(right: 24.0)),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              Text('Valor: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Expanded(
                                                  child: Text(CurrencyInputFormatter.valueFormatter(docCall.value),
                                                      style: TextStyle(fontSize: 16.0))),
                                              Text('Disponível: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              Text(docCall.available ? 'Sim' : 'Não', style: TextStyle(fontSize: 16.0)),
                                              Padding(padding: EdgeInsets.only(right: 24.0)),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),
                                          Container(
                                            child: StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(docCall.ownerUid)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData && snapshot.data.data != null)
                                                  return getDoctorInfo(snapshot.data, false);
                                                else
                                                  switch (snapshot.connectionState) {
                                                    case ConnectionState.waiting:
                                                      return Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CircularProgressIndicator(
                                                              backgroundColor: Theme.of(context).primaryColor,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    default:
                                                      return Container();
                                                  }
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 16.0),
                                          docCall.requestorUid != null
                                              ? Container(
                                                  child: StreamBuilder<DocumentSnapshot>(
                                                    stream: FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(docCall.requestorUid)
                                                        .snapshots(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasData && snapshot.data.data != null)
                                                        return getDoctorInfo(snapshot.data, true);
                                                      else
                                                        switch (snapshot.connectionState) {
                                                          case ConnectionState.waiting:
                                                            return Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CircularProgressIndicator(
                                                                    backgroundColor: Theme.of(context).primaryColor,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          default:
                                                            return Container();
                                                        }
                                                    },
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    );
                                  } else
                                    return Container();
                                },
                              ),
                            ),
                            isExpanded: _data[0].isExpanded,
                          ),
//                        ExpansionPanel(
//                          headerBuilder: (BuildContext context, bool isExpanded) {
//                            return Container(
//                              padding: EdgeInsets.only(left: 16.0, top: 8.0),
//                              child: Text(
//                                _data[1].headerValue,
//                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                              ),
//                            );
//                          },
//                          body: Container(
//                            padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
//                            child: Column(
//                              children: [],
//                            ),
//                          ),
//                          isExpanded: _data[1].isExpanded,
//                        )
                        ],
                      ),
                      SizedBox(height: 24.0),
                      docCall.ownerUid != userBloc.firebaseUser.uid &&
                              docCall.date.isAfter(DateTime.now()) &&
                              (docCall.requestorUid == userBloc.firebaseUser.uid ||
                                  docCall.available ||
                                  docCall.requestorUid == null)
                          ? SizedBox(
                              height: 48.0,
                              width: MediaQuery.of(context).size.width,
                              child: RaisedButton(
                                child: Text(
                                  docCall.available ? 'Solicitar' : 'Cancelar',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                                textColor: Theme.of(context).accentColor,
                                color: docCall.available ? Theme.of(context).primaryColor : Colors.redAccent,
                                onPressed: () {
                                  var values = {
                                    'doctorCallUid': docCall.uid,
                                    'requestorUid': userBloc.firebaseUser.uid,
                                  };
                                  doctorCallBloc.requestCancelDoctorCall(values, (isSolicitation) {
                                    _onSuccess(isSolicitation);
                                    return;
                                  }, _onFail);
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor),
                    Text('Carregando...'),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Container getdoctorImg(DocumentSnapshot doc) {
    if (doc != null && doc.data() != null && doc.get('profileImgURL') != null)
      return Container(
        height: 80.0,
        width: 80.0,
        child: CircleAvatar(
          radius: 20.0,
          backgroundImage: NetworkImage(doc.data()['profileImgURL']),
        ),
      );
    else
      return Container(
        height: 80.0,
        width: 80.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('images/doctor.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      );
  }

  Container getDoctorInfo(DocumentSnapshot doc, bool owner) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(owner ? 'Solicitado Por:' : 'Repassado Por:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              getdoctorImg(doc),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Dr(a). ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                        Expanded(child: Text('${doc['name']}', style: TextStyle(fontSize: 16.0))),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Text('CRM nº: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                        Expanded(flex: 3, child: Text('${doc['crm']}', style: TextStyle(fontSize: 16.0))),
                        Text('Estado: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                        Expanded(flex: 1, child: Text('${doc['uf']}', style: TextStyle(fontSize: 16.0))),
                      ],
                    ),
                    doc['celPhone'] != null
                        ? Row(
                            children: [
                              Text('Contato: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                              Expanded(
                                child: MaterialButton(
                                  padding: EdgeInsets.all(0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 25.0,
                                          child: Image.asset(
                                            'images/whatsapp.png',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          '${doc['celPhone']}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    var celPhone = doc['celPhone']
                                        .toString()
                                        .replaceAll(' ', '')
                                        .replaceAll('(', '')
                                        .replaceAll(')', '')
                                        .replaceAll('-', '');
                                    whatsAppOpen(celPhone);
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
          doc.data().containsKey('pix')
              ? Row(
                  children: [
                    Text('Chave Pix: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup(context: context, builder: (_) => copyWidget('${doc['pix']}'));
                        },
                        child: Text(
                          '${doc['pix']}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  void _onSuccess(isSolicitation) {
    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
      content: Text(isSolicitation ? 'Solicitação realizada com sucesso' : 'Cancelamento realizada com sucesso'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }

  void _onFail() {
    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
      content: Text('Falha ao efetuar solicitação'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  void whatsAppOpen(String phone) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/55$phone/?text=${Uri.parse('Oi!')}";
      } else {
        return "whatsapp://send?phone=55$phone&text=${Uri.parse('Oi!')}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
        content: Text('Não foi possível abrir o WhatsApp.'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ));
    }
  }

  Widget copyWidget(String pix) {
    if (Platform.isAndroid)
      return BottomSheet(
        onClosing: () {},
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FlatButton(
              onPressed: () async {
                Clipboard.setData(new ClipboardData(text: pix));
              },
              child: const Text('Copiar Chave Pix'),
            ),
          ],
        ),
      );
    else
      return CupertinoActionSheet(
        title: const Text('Chave Pix'),
        message: const Text('Deseja copiar chave Pix?'),
        cancelButton: CupertinoActionSheetAction(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Clipboard.setData(new ClipboardData(text: pix));
            },
            child: const Text('Copiar'),
          )
        ],
      );
  }
}

class Item {
  Item(this.headerValue, {this.isExpanded = false});
  String headerValue;
  bool isExpanded;
  Widget body;
}
