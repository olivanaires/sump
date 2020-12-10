import 'package:flutter/material.dart';
import 'package:sumpapp/widgets/custom_drawer.dart';

class UserNotVaildScreen extends StatelessWidget {
  final pageController;

  UserNotVaildScreen(this.pageController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(pageController),
      appBar: AppBar(
        toolbarHeight: 90.0,
        title: Text(
          'Sistema único \nMédico Plantonista',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Seu usuário ainda não foi validado pela equipe SUMP.'),
      ),
    );
  }
}
