import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProviderList.of<UserBloc>(context);

    return ScaffoldMessenger(
      key: _scaffoldMessageKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Entrar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            FlatButton(
              textColor: Colors.white,
              child: Text(
                'CRIAR CONTA',
                style: TextStyle(fontSize: 12.0),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
            ),
          ],
        ),
        body: StreamBuilder<bool>(
            stream: userBloc.isLoading,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data)
                return Center(child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor));

              return Form(
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: 'E-Mail'),
                      validator: (text) {
                        if (text.isEmpty) return "E-Mail deve ser informado.";
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: 'Senha'),
                      obscureText: true,
                      validator: (text) {
                        if (text.isEmpty) return "Senha deve ser informada.";
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        _requestResetPassword(context, _emailController.text);
                      },
                      child: Text(
                        "Esqueceu a senha?",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      height: 44.0,
                      child: RaisedButton(
                        child: Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        textColor: Theme.of(context).accentColor,
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          userBloc.signIn(
                            email: _emailController.text,
                            pass: _passwordController.text,
                            onSuccess: _onSuccess,
                            onFail: () => _onFail(null),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        'ou',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      heightFactor: 2,
                    ),
                    SignInButton(
                      Buttons.Google,
                      text: "Entrar com Google",
                      onPressed: () {
                        userBloc.signInWithGoogle(
                          onSuccess: _onSuccess,
                          onFail: () => _onFail('Você ainda não se registrou.'),
                        );
                      },
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }

  Future<bool> _requestResetPassword(BuildContext context, String email) {
    final userBloc = BlocProviderList.of<UserBloc>(context);
    showDialog(
        context: context,
        builder: (context) {
          var msg = email.isEmpty
              ? 'Informe o campo e-mail para o qual deve ser enviado o email para resetar senha'
              : 'Um email sera enviado para $email com instruções para resetar sua senha.';
          return AlertDialog(
            title: Text("Resetar Senha?"),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              email.isEmpty
                  ? Container()
                  : FlatButton(
                      child: Text("Enviar"),
                      onPressed: () {
                        userBloc.recoverPass(email);
                        Navigator.pop(context);
                      },
                    ),
            ],
          );
        });
    return Future.value(false);
  }

  void _onSuccess() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _onFail(error) {
    _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
      content: error != null ? Text(error) : Text('Falha ao se logar.'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
