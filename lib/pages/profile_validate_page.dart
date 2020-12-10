import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumpapp/blocs/user_bloc.dart';

class ProfileValidatePage extends StatefulWidget {
  @override
  _ProfileValidatePageState createState() => _ProfileValidatePageState();
}

class _ProfileValidatePageState extends State<ProfileValidatePage> {
  final ImagePicker picker = ImagePicker();

  bool _picked = false;
  File perfilPictureFile;
  File identityPictureFile;
  Future<PickedFile> perfilPictureImageFile;
  Future<PickedFile> identityPictureImageFile;

  takePerfilPicture(ImageSource source) {
    setState(() {
      perfilPictureImageFile = picker.getImage(source: source);
      _picked = true;
    });
  }

  takeIdentityPicture(ImageSource source) {
    setState(() {
      identityPictureImageFile = picker.getImage(source: source);
      _picked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('widget.title'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => takePerfilPicture(ImageSource.camera),
                  child: showPerfilPicture(),
                ),
                GestureDetector(
                  onTap: () => takeIdentityPicture(ImageSource.camera),
                  child: showIdentityPicture(),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 44.0,
                  child: RaisedButton(
                    child: Text(
                      'Enviar',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).accentColor,
                    onPressed: () {
                      if (perfilPictureFile != null)
                        userBloc.updateImgValidateProfile(perfilPictureFile, 'perfilPicture');
                      if (identityPictureFile != null)
                        userBloc.updateImgValidateProfile(identityPictureFile, 'identityPicture');

                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_picked) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Widget showPerfilPicture() {
    return FutureBuilder<PickedFile>(
      future: perfilPictureImageFile,
      builder: (BuildContext context, AsyncSnapshot<PickedFile> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          perfilPictureFile = File(snapshot.data.path);
          return Image.file(
            perfilPictureFile,
            width: 300,
            height: 300,
          );
        } else {
          return Container(
            height: 250.0,
            width: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                image: AssetImage('images/person.png'),
                fit: BoxFit.fill,
              ),
            ),
          );
        }
      },
    );
  }

  Widget showIdentityPicture() {
    return FutureBuilder<PickedFile>(
      future: identityPictureImageFile,
      builder: (BuildContext context, AsyncSnapshot<PickedFile> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          identityPictureFile = File(snapshot.data.path);
          return Image.file(
            identityPictureFile,
            width: 300,
            height: 300,
          );
        } else {
          return Container(
            height: 250.0,
            width: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                image: AssetImage('images/identity-card.png'),
                fit: BoxFit.fill,
              ),
            ),
          );
        }
      },
    );
  }
}
