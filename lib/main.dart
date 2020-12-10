import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sumpapp/blocs/doctor_call_bloc.dart';
import 'package:sumpapp/blocs/group_bloc.dart';
import 'package:sumpapp/blocs/hospital_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/helpers/bloc_helper.dart';
import 'package:sumpapp/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // ToDo retorna tela de erro, contactar admin
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return BlocProviderList(
            listBloc: [
              Bloc(UserBloc()),
              Bloc(DoctorCallBloc()),
              Bloc(HospitalBloc()),
              Bloc(GroupBloc()),
              Bloc(BlocHelper()),
            ],
            child: MaterialApp(
              title: 'SUMP',
              debugShowCheckedModeBanner: false,
//              localizationsDelegates: [
//                GlobalMaterialLocalizations.delegate,
//                GlobalWidgetsLocalizations.delegate,
//                GlobalCupertinoLocalizations.delegate,
//              ],
              theme: ThemeData(
                primaryColor: Colors.green,
                accentColor: Colors.white,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
//              supportedLocales: [const Locale('pt', 'BR')],
              home: HomeScreen(),
            ),
          );
        }

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
      },
    );
  }
}
