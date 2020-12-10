import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/model/user_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  final _passwordController = TextEditingController();
  final _passwordConfirController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    UserModel userModel = UserModel();

    return ScaffoldMessenger(
      key: _scaffoldMessageKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Registe-se',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Container(
                height: 250.0,
                child: Image.asset(
                  'images/logo_v2.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'Nome', labelText: 'Nome'),
                textCapitalization: TextCapitalization.words,
                onSaved: (newValue) => userModel.name = newValue,
                validator: (text) {
                  if (text.isEmpty) return 'Nome deve ser informado.';
                  if (text.length < 2 || text.length > 50) return 'Nome deve ter tamanho entre 2 e 10.';
                  return null;
                },
              ),
//            SizedBox(height: 8.0),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'E-Mail', labelText: 'E-Mail'),
                onSaved: (newValue) => userModel.email = newValue,
                validator: (text) {
                  if (text.isEmpty) return 'E-Mail deve ser informado.';

                  bool emailValid =
                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
                  if (!emailValid) return 'E-Mail inválido.';
                  return null;
                },
              ),
              SizedBox(height: 8.0),
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
              SizedBox(height: 24.0),
              SizedBox(
                height: 44.0,
                child: RaisedButton(
                  child: Text(
                    'Registrar',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  textColor: Theme.of(context).accentColor,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      userBloc.signUp(
                        userData: userModel.toMap(),
                        pass: _passwordController.text,
                        onSuccess: _onSuccess,
                        onFail: (error) {
                          _onFail(error);
                          return;
                        },
                      );
                    }
                  },
                ),
              ),
//            Center(
//              child: Text(
//                'ou',
//                style: TextStyle(
//                  fontWeight: FontWeight.bold,
//                  fontSize: 16.0,
//                ),
//              ),
//              heightFactor: 2,
//            ),
//            SignInButton(
//              Buttons.Google,
//              text: "Registrar com Google",
//              onPressed: () {
//                userBloc.signUpWithGoogle(
//                    onSuccess: _onSuccess,
//                    onFail: (error) {
//                      _onFail(error);
//                      return;
//                    });
//              },
//            )
            ],
          ),
        ),
      ),
    );
  }

  void _onSuccess() {
    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
      content: Text('Registrado com sucesso'),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 2),
    ));

    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.of(context).pop();
    });
  }

  void _onFail(error) {
    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
      content: Text(error ?? 'Falha ao registra-se'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
