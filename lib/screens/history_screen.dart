import 'package:flutter/material.dart';
import 'package:sumpapp/tabs/history/history_doctor_call_tab.dart';
import 'package:sumpapp/tabs/history/history_hospital_tab.dart';
import 'package:sumpapp/tabs/history/history_my_offer_doc_call_tab.dart';
import 'package:sumpapp/widgets/custom_drawer.dart';

class HistoryScreen extends StatelessWidget {
  final _pageController;

  HistoryScreen(this._pageController);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: CustomDrawer(_pageController),
        appBar: AppBar(
          toolbarHeight: 90.0,
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              'Meus Plantões',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: 'Plantões'),
              Tab(text: 'Repasses'),
              Tab(text: 'Hospitais'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HistoryDoctorCallTab(),
            HistoryMyOfferDocCallTab(),
            HistoryHospitalTab(),
          ],
        ),
      ),
    );
  }
}
