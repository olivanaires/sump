import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/invitations_model.dart';
import 'package:sumpapp/model/status.dart';

class MyGroupInvitationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: userBloc.loadInvitationsUsers(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            Invitations invitations = Invitations.fromDocument(document);
            return CreateCard(invitations);
          }).toList(),
        );
      },
    );
  }
}

class CreateCard extends StatelessWidget {
  final Invitations _invitations;
  CreateCard(this._invitations);

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Text.rich(TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: '${_invitations.nameRequester} ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            TextSpan(text: 'convidou você para partipar do grupo ', style: TextStyle(fontSize: 17)),
                            TextSpan(text: '${_invitations.name}. ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ],
                        ))),
                        // Expanded(child: Text("${_invitations.nameRequester} convidou você para partipar do Grupo ${_invitations.name} ")),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 120,
                            child: RaisedButton(
                              child: Text(
                                'Confirmar',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              color: Theme.of(context).primaryColor,
                              textColor: Theme.of(context).accentColor,
                              onPressed: () {
                                userBloc.updateGroups(_invitations.id, _invitations.grouId, STATUS.APPROVED);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Você aceitou partipar no grupo'),
                                  backgroundColor: Theme.of(context).primaryColor,
                                  duration: Duration(seconds: 2),
                                ));
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(right: 24.0)),
                          SizedBox(
                            width: 120,
                            child: RaisedButton(
                              child: Text(
                                'Excluir',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              color: Colors.grey,
                              textColor: Colors.black,
                              onPressed: () {
                                userBloc.updateGroups(_invitations.id, _invitations.grouId, STATUS.OFF);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Você recusou partipar do grupo'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
