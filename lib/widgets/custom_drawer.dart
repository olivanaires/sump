import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/screens/home_screen.dart';
import 'package:sumpapp/screens/login_screen.dart';
import 'package:sumpapp/tiles/drawer_tile.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;

  CustomDrawer(this.pageController);

  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);

    Widget _buildDrawerBack() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 203, 236, 241),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

    return StreamBuilder<DocumentSnapshot>(
        stream: _userBloc.loadUser(),
        initialData: null,
        builder: (context, snapshot) {
          bool valid = snapshot.hasData && snapshot.data.data() != null && snapshot.data['valid'];
          return Drawer(
            child: Stack(
              children: <Widget>[
                _buildDrawerBack(),
                ListView(
                  padding: EdgeInsets.only(top: 56.0),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'images/logo_v2.jpg',
                        fit: BoxFit.fitHeight,
                        height: 130.0,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      padding: EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Olá, ${snapshot.hasData && snapshot.data.data() != null ? snapshot.data['name'] : ""}',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () {
                              if (snapshot.data != null) {
                                _userBloc.signOut();
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
                              } else
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  snapshot.data != null ? 'Sair' : 'Entre ou Cadastre-se',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      child: snapshot.hasData && snapshot.data != null
                          ? Column(
                              children: [
                                DrawerTile(Icons.home, 'Início', pageController, 0),
                                DrawerTile(Icons.person, 'Perfil', pageController, 1),
                                valid ? DrawerTile(Icons.dashboard, 'Quadro de Repasses', pageController, 2) : Container(),
                                valid ? DrawerTile(Icons.group, 'Grupos', pageController, 3) : Container(),
                                valid ? DrawerTile(Icons.history, 'Meus Agendamentos', pageController, 4) : Container(),
                              ],
                            )
                          : Container(),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
