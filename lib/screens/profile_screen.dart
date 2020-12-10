import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/doctor_model.dart';
import 'package:sumpapp/pages/profile_validate_page.dart';
import 'package:sumpapp/tiles/image_source_tile.dart';
import 'package:sumpapp/widgets/custom_drawer.dart';
import 'package:sumpapp/widgets/masked_textfield.dart';

class ProfileScreen extends StatelessWidget {
  final pageController;

  ProfileScreen(this.pageController);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);

    File _image;

    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _cpfController = TextEditingController();
    final _crmController = TextEditingController();
    final _ufController = TextEditingController();
    final _celPhoneController = TextEditingController();
    final _pixController = TextEditingController();
    // address
    final _streetController = TextEditingController();
    final _streetNumberController = TextEditingController();
    final _neigborhoodController = TextEditingController();
    final _cityController = TextEditingController();
    final _stateController = TextEditingController();
    final _cepController = TextEditingController();

    DoctorModel doctorModel = DoctorModel();

    final _formKey = GlobalKey<FormState>();

    void onImageSelected(PickedFile file) {
      if (file != null) {
        _image = File(file.path);
        _userBloc.updateImgProfile(_image);
      }
      Navigator.of(context).pop();
    }

    return ScaffoldMessenger(
      key: _scaffoldMessageKey,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: CustomDrawer(pageController),
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 90.0,
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              'Perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  doctorModel.cpf = _cpfController.text;
                  doctorModel.cep = _cepController.text;
                  doctorModel.celPhone = _celPhoneController.text;
                  _userBloc.updateProfile(doctorModel.toMap(), () => _onSuccess(context), () => _onFail(context));
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
              child: Text("SALVAR"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
          child: Column(
            children: [
              GestureDetector(
                child: Center(
                  child: StreamBuilder<Map<String, dynamic>>(
                      stream: _userBloc.userData,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data['profileImgURL'] != null)
                          return Container(
                            height: 160.0,
                            width: 160.0,
                            child: CircleAvatar(
                              radius: 30.0,
                              backgroundImage: NetworkImage(snapshot.data['profileImgURL']),
                            ),
                          );
                        else
                          return Container(
                            height: 160.0,
                            width: 160.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('images/person.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                      }),
                ),
                onTap: () async {
                  showCupertinoModalPopup(
                      context: context, builder: (_) => ImageSourceTile(onImageSelected: onImageSelected));
                },
              ),
              StreamBuilder<Map<String, dynamic>>(
                stream: _userBloc.userData,
                builder: (context, snapshot) {
                  var type = UserBloc.USER_TYPE_DEFAULT;
                  var valid = snapshot.hasData && snapshot.data['valid'];
                  if (snapshot.hasData) {
                    _nameController.text = snapshot.data['name'];
                    _emailController.text = snapshot.data['email'];
                    _celPhoneController.text = snapshot.data['celPhone'];
                    _pixController.text = snapshot.data['pix'];

                    _cpfController.text = snapshot.data['cpf'];
                    _crmController.text = snapshot.data['crm'];
                    _ufController.text = snapshot.data['uf'];

                    _streetController.text = snapshot.data['street'];
                    _streetNumberController.text = snapshot.data['streetNumber'];
                    _neigborhoodController.text = snapshot.data['neigborhood'];
                    _cityController.text = snapshot.data['city'];
                    _stateController.text = snapshot.data['state'];
                    _cepController.text = snapshot.data['cep'];
                    type = snapshot.data['type'];
                  }
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Dados Pessoais',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Nome Completo', hintText: 'Nome Completo'),
                          textCapitalization: TextCapitalization.words,
                          onSaved: (newValue) => doctorModel.name = newValue,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'E-Mail', hintText: 'E-Mail'),
                          enabled: false,
                          onSaved: (newValue) => doctorModel.email = newValue,
                        ),
                        MaskedTextField(
                          maskedTextFieldController: _cpfController,
                          inputDecoration: InputDecoration(labelText: 'CPF', hintText: 'CPF', counterText: ''),
                          maxLength: 14,
                          keyboardType: TextInputType.number,
                          mask: 'xxx.xxx.xxx-xx',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _crmController,
                                decoration: InputDecoration(labelText: 'CRM', hintText: 'CRM'),
                                keyboardType: TextInputType.number,
                                onSaved: (newValue) => doctorModel.crm = newValue,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 10.0)),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _ufController,
                                decoration: InputDecoration(labelText: 'UF', hintText: 'UF', counterText: ''),
                                maxLength: 2,
                                textCapitalization: TextCapitalization.characters,
                                onSaved: (newValue) => doctorModel.uf = newValue,
                              ),
                            ),
                          ],
                        ),
                        MaskedTextField(
                          maskedTextFieldController: _celPhoneController,
                          inputDecoration: InputDecoration(labelText: 'Celular', hintText: 'Celular', counterText: ''),
                          maxLength: 15,
                          keyboardType: TextInputType.number,
                          mask: '(xx) xxxxx-xxxx',
                        ),
                        TextFormField(
                          controller: _pixController,
                          decoration: InputDecoration(labelText: 'Chave Pix', hintText: 'Chave Pix'),
                          textCapitalization: TextCapitalization.characters,
                          onSaved: (newValue) => doctorModel.pix = newValue,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 24.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Endereço',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _streetController,
                                decoration: InputDecoration(labelText: 'Logradouro', hintText: 'Logradouro'),
                                textCapitalization: TextCapitalization.words,
                                onSaved: (newValue) => doctorModel.street = newValue,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 10.0)),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _streetNumberController,
                                decoration: InputDecoration(labelText: 'Número', hintText: 'Número'),
                                keyboardType: TextInputType.number,
                                onSaved: (newValue) => doctorModel.streetNumber = newValue,
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _neigborhoodController,
                          decoration: InputDecoration(labelText: 'Bairro', hintText: 'Bairro'),
                          textCapitalization: TextCapitalization.words,
                          onSaved: (newValue) => doctorModel.neigborhood = newValue,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(labelText: 'Cidade', hintText: 'Cidade'),
                                textCapitalization: TextCapitalization.words,
                                onSaved: (newValue) => doctorModel.city = newValue,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(right: 10.0)),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _stateController,
                                decoration: InputDecoration(labelText: 'Estado', hintText: 'Estado', counterText: ''),
                                maxLength: 2,
                                textCapitalization: TextCapitalization.characters,
                                onSaved: (newValue) => doctorModel.state = newValue,
                              ),
                            ),
                          ],
                        ),
                        MaskedTextField(
                          maskedTextFieldController: _cepController,
                          inputDecoration: InputDecoration(labelText: 'CEP', hintText: 'CEP', counterText: ''),
                          maxLength: 9,
                          keyboardType: TextInputType.number,
                          mask: 'xxxxx-xxx',
                        ),
                        !valid
                            ? Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 44.0,
                                  child: RaisedButton(
                                    child: Text(
                                      'Validar Cadastro',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    textColor: Theme.of(context).accentColor,
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (context) => ProfileValidatePage()));
                                    },
                                  ),
                                ),
                              )
                            : Container(),
                        type == UserBloc.USER_TYPE_DEFAULT
                            ? Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 44.0,
                                  child: RaisedButton(
                                    child: Text(
                                      'Alterar Senha',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    textColor: Theme.of(context).accentColor,
                                    onPressed: () {
                                      _requestResetPassword(context);
                                    },
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.save),
//        onPressed: () {
//          if (_formKey.currentState.validate()) {
//            _formKey.currentState.save();
//            doctorModel.cpf = _cpfController.text;
//            doctorModel.cep = _cepController.text;
//            doctorModel.celPhone = _celPhoneController.text;
//            userBloc.updateProfile(doctorModel.toMap(), _onSuccess, _onFail);
//            FocusScope.of(context).requestFocus(FocusNode());
//          }
//        },
//      ),
      ),
    );
  }

  Future<bool> _requestResetPassword(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    final _formKey = GlobalKey<FormState>();
    final _passwordController = TextEditingController();
    final _passwordConfirController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Resetar Senha?"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: 'Senha', labelText: 'Senha'),
                    obscureText: true,
                    validator: (text) {
                      if (text.length < 8) return 'Senha deve ter tamanho mínimo 8.';
                      if (text.isEmpty) return 'Senha deve ser informado.';
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: _passwordConfirController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: 'Confirmar Senha', labelText: 'Confirmar Senha'),
                    obscureText: true,
                    validator: (text) {
                      if (text.isEmpty) return 'Confirmar Senha deve ser informado.';
                      if (_passwordController.text != text) return 'Confirmar Senha deve ser igual a Senha.';
                      return null;
                    },
                  ),
                ],
              ),
            ),
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
                  if (_formKey.currentState.validate()) {
                    userBloc.changePass(_passwordController.text);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
    return Future.value(false);
  }

  void _onSuccess(BuildContext context) {
    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
      content: Text('Registrado com sucesso'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }

  void _onFail(BuildContext context) {
    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
      content: Text('Falha ao registra-se'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
