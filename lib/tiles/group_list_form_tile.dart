import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/group_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/group.dart';
import 'package:sumpapp/model/status.dart';
import 'package:sumpapp/model/user_model.dart';

// ignore: must_be_immutable
class GroupListFormTile extends StatefulWidget {
  Group group;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  GroupListFormTile(this.group, this._scaffoldKey);

  @override
  _GroupFormTileState createState() => _GroupFormTileState();
}

class _GroupFormTileState extends State<GroupListFormTile> {
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _groupName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);
    final _grouBloc = BlocProviderList.of<GroupBloc>(context);

    if (widget.group.name != null) _groupName.text = widget.group.name;

    var isAdminOrNewGroup = widget.group.userId == null || widget.group.userId == _userBloc.firebaseUser.uid || widget.group.id == null;

    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        title: Text('Gerenciar Grupo'),
        actions: <Widget>[
          isAdminOrNewGroup
              ? FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    createGroup(context);
                  },
                  child: Text("SALVAR"),
                  shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                )
              : FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    leaveGroup(context, _userBloc.firebaseUser.uid);
                  },
                  child: Text("SAIR"),
                  shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _groupName,
              decoration: InputDecoration(labelText: 'Nome do Grupo'),
              enabled: isAdminOrNewGroup,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Nome do grupo é obrigatório.';
                } else {
                  return null;
                }
              },
            ),
            isAdminOrNewGroup
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              backgroundImage: AssetImage('images/add_person.png'),
                            ),
                            title: Text(
                              "Adicionar Médicos ao grupo",
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    String contentText = "";
                                    String send = "Salvar";
                                    bool isExist = false;
                                    final StreamController<String> _contextTextController = StreamController<String>();

                                    @override
                                    void dispose() {
                                      _contextTextController.close();
                                      super.dispose();
                                    }

                                    return AlertDialog(
                                      shape:
                                          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                      content: Container(
                                        height: 200,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                autofocus: true,
                                                controller: _doctorController,
                                                decoration: InputDecoration(hintText: "Informe um E-mail"),
                                                validator: (text) {
                                                  if (text.isEmpty) return 'E-Mail deve ser informado.';

                                                  bool emailValid = RegExp(
                                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                      .hasMatch(text);
                                                  if (!emailValid) return 'E-Mail inválido.';
                                                  return null;
                                                },
                                              ),
                                              StreamBuilder<String>(
                                                stream: _contextTextController.stream,
                                                initialData: "",
                                                builder: (context, snapshot) {
                                                  return Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: new Text("${snapshot.data}",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        )),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        StreamBuilder<Map<String, dynamic>>(
                                          stream: _userBloc.userData,
                                          builder: (context, snapshot) {
                                            return new FlatButton(
                                              child: new Text(send),
                                              onPressed: () async {
                                                if (_formKey.currentState.validate()) {
                                                  UserModel user = await _userBloc.isExistsUser(_doctorController.text);

                                                  if (_userBloc.firebaseUser.uid == user.uid) {
                                                    widget._scaffoldKey.currentState.showSnackBar(SnackBar(
                                                      content: Text(
                                                        'Você ja faz parte do Grupo.',
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                      backgroundColor: Colors.red,
                                                      duration: Duration(seconds: 2),
                                                    ));
                                                    _doctorController.text = '';
                                                    Navigator.pop(context);
                                                  } else {
                                                    Map<String, dynamic> userData = {};
                                                    if (isExist) {
                                                      userData["status"] = STATUS.INVITATION;
                                                      userData["email"] = _doctorController.text;
                                                      userData["type"] = 'MEMBER';
                                                      userData["requester"] = _userBloc.firebaseUser.email;
                                                      userData["name_requester"] = snapshot.data['name'];
                                                      _addDoctor(userData);
                                                      Navigator.pop(context);
                                                    } else if (user.uid == null) {
                                                      isExist = true;
                                                      contentText = "Email não cadastrado, deseja enviar um convite ?";
                                                      _contextTextController.sink.add(contentText);
                                                    } else {
                                                      userData["userId"] = user.uid;
                                                      userData["userName"] = user.name;
                                                      userData["email"] = user.email;
                                                      userData["type"] = 'MEMBER';
                                                      userData["status"] = STATUS.PENDING;
                                                      userData["requester"] = _userBloc.firebaseUser.email;
                                                      userData["name_requester"] = snapshot.data['name'];
                                                      _addDoctor(userData);
                                                      Navigator.pop(context);
                                                    }
                                                  }
                                                }
                                              },
                                            );
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                          ),
                          // child: Text(
                          //   widget.group.users.length > 0 ? 'Médicos Cadastrados' : 'Cadastrar médico ao grupo',
                          //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          // ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.group.users.length,
                itemBuilder: (context, index) {
                  var description = widget.group.users[index]["userName"] != null
                      ? widget.group.users[index]["userName"]
                      : widget.group.users[index]["email"];

                  if (!isAdminOrNewGroup ||
                      (widget.group.users[index].containsKey('type') && widget.group.users[index]['type'] == 'ADMIN'))
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage('images/person.png'),
                          ),
                          title: Text(description),
                        ),
                        Divider(
                          color: Colors.black26,
                        )
                      ],
                    );

                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                        padding: EdgeInsets.only(left: 320.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        color: Colors.red),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      _grouBloc.removeUserInGroups(widget.group, index);
                      widget._scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Usuário removido com sucesso.'),
                        backgroundColor: Theme.of(context).primaryColor,
                        duration: Duration(seconds: 2),
                      ));
                    },
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage('images/person.png'),
                          ),
                          title: Text(description),
                        ),
                        Divider(
                          color: Colors.black26,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addDoctor(data) {
    setState(() {
      widget.group.users.add(data);
    });
    _doctorController.text = "";
  }

  void createGroup(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);
    final groupBloc = BlocProviderList.of<GroupBloc>(context);
    final String doctorName = _groupName.text;
    widget.group.userId = userBloc.firebaseUser.uid;

    final newGroup =
        Group(widget.group.id, doctorName, userBloc.firebaseUser.uid, widget.group.users, userBloc.firebaseUser.email);

    groupBloc.createGroup(newGroup);
    Navigator.pop(context, newGroup);
  }

  void leaveGroup(BuildContext context, String userUid) async {
    final groupBloc = BlocProviderList.of<GroupBloc>(context);
    groupBloc.leaveGroup(widget.group, userUid);
    Navigator.pop(context, widget.group);
  }
}

class CreateCard extends StatelessWidget {
  final String _email;
  final VoidCallback onDelete;

  CreateCard(this._email, {this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(_email.toString()),
      ),
    );
  }
}
