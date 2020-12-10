import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/doctor_call_bloc.dart';
import 'package:sumpapp/blocs/user_bloc.dart';
import 'package:sumpapp/helpers/bloc_helper.dart';
import 'package:sumpapp/pages/my_new_call_offer_page.dart';
import 'package:sumpapp/tabs/doctor_calls/doctor_call_group_tab.dart';
import 'package:sumpapp/tabs/doctor_calls/doctor_call_tab.dart';
import 'package:sumpapp/tiles/doctor_call/doctor_call_filter_tile.dart';
import 'package:sumpapp/widgets/custom_drawer.dart';

class DoctorCallsBoardScreen extends StatelessWidget {
  final _pageController;

  DoctorCallsBoardScreen(this._pageController);

  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);
    final _doctorCallBloc = BlocProviderList.of<DoctorCallBloc>(context);
    final _blocHelper = BlocProviderList.of<BlocHelper>(context);
    _blocHelper.tabChange(0);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: CustomDrawer(_pageController),
        endDrawer: DoctorCallFilterTile(),
        appBar: AppBar(
          toolbarHeight: 90.0,
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              'Quadro de Repasses',
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
              Tab(text: 'Geral'),
              Tab(text: 'Grupo'),
            ],
            onTap: (index) {
              _blocHelper.tabChange(index);
            },
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.search),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Theme.of(context).accentColor),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => MyNewCallOfferPage()))
                .then((value) => _blocHelper.tabChange(1));
          },
        ),
        body: TabBarView(
          children: [
            DoctorCallTab(),
            DoctorCallGroupTab(),
          ],
        ),
      ),
    );
  }
}
