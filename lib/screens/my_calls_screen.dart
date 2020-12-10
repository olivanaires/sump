import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/helpers/bloc_helper.dart';
import 'package:sumpapp/tabs/my_calls/my_calls_offer_tab.dart';
import 'package:sumpapp/tabs/my_calls/my_calls_tab.dart';
import 'package:sumpapp/pages/my_new_call_offer_page.dart';
import 'package:sumpapp/widgets/custom_drawer.dart';

class MyCallsScreen extends StatefulWidget {
  final _pageController;

  MyCallsScreen(this._pageController);

  @override
  _MyCallsScreenState createState() => _MyCallsScreenState(_pageController);
}

class _MyCallsScreenState extends State<MyCallsScreen> {
  final _pageController;

  _MyCallsScreenState(this._pageController);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final _blocHelper = BlocProviderList.of<BlocHelper>(context);
    _blocHelper.tabChange(0);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        key: _scaffoldKey,
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
            onTap: (index) {
              _blocHelper.tabChange(index);
            },
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: 'Plantões'),
              Tab(text: 'Repasses'),
            ],
          ),
        ),
        floatingActionButton: StreamBuilder(
          initialData: 0,
          stream: _blocHelper.selectedTab,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == 1)
              return FloatingActionButton(
                child: Icon(Icons.add, color: Theme.of(context).accentColor),
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => MyNewCallOfferPage()))
                      .then((value) => _blocHelper.tabChange(1));
                },
              );
            return Container();
          },
        ),
        body: TabBarView(
          children: [
            MyCallTab(),
            MyOfferCallTab(_scaffoldMessageKey),
          ],
        ),
      ),
    );
  }
}
