import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sumpapp/blocs/favorite_hospital_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/helpers/page_manager_provider.dart';
import 'package:sumpapp/screens/doctor_calls_board_screen.dart';
import 'package:sumpapp/screens/group_screen.dart';
import 'package:sumpapp/screens/history_screen.dart';
import 'package:sumpapp/screens/profile_screen.dart';
import 'package:sumpapp/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pageController = PageController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    configFCM();
  }

  void configFCM() {
    final fcm = FirebaseMessaging();

    if (Platform.isIOS) {
      fcm.requestNotificationPermissions(const IosNotificationSettings(provisional: true));
    }

    fcm.configure(onLaunch: (Map<String, dynamic> message) async {
      print('onLaunch $message');
    }, onResume: (Map<String, dynamic> message) async {
      print('onResume $message');
    }, onMessage: (Map<String, dynamic> message) async {
      showNotification(
        message['notification']['title'] as String,
        message['notification']['body'] as String,
      );
    });
  }

  void showNotification(String title, String message) {
    Flushbar(
      title: title,
      message: message,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      isDismissible: true,
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 5),
      icon: Icon(
        Icons.compare_arrows,
        color: Colors.white,
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc _userBloc = BlocProviderList.of<UserBloc>(context);

    return Provider(
      create: (_) => PageManager(pageController),
      child: BlocProvider(
        bloc: FavoritHospitalBloc(_userBloc.firebaseUser?.uid),
        child: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Scaffold(
              appBar: AppBar(
                toolbarHeight: 90.0,
                title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    'Sistema único \nMédico Plantonista',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                centerTitle: true,
              ),
              drawer: CustomDrawer(pageController),
            ),
            Scaffold(body: ProfileScreen(pageController)),
            Scaffold(body: DoctorCallsBoardScreen(pageController)),
            Scaffold(body: GroupScreen(pageController)),
            Scaffold(body: HistoryScreen(pageController)),
          ],
        ),
      ),
    );
  }
}
