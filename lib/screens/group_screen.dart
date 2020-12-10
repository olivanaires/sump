// Meus grupos
// Criar grupo
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/helpers/bloc_helper.dart';
import 'package:sumpapp/model/group.dart';
import 'package:sumpapp/screens/group/form.dart';
import 'package:sumpapp/tabs/groups/my_groups_invitations_tab.dart';
import 'package:sumpapp/tabs/groups/my_groups_tab.dart';
// import 'package:sumpapp/tabs/my_groups_invitations_tab.dart';
// import 'package:sumpapp/tabs/my_groups_tab.dart';
import 'package:sumpapp/widgets/custom_drawer.dart';

class GroupScreen extends StatefulWidget {
  final List<Group> _groups = List();
  final _pageController;

  GroupScreen(this._pageController);

  @override
  State<StatefulWidget> createState() {
    return GroupListState();
  }
}

class GroupListState extends State<GroupScreen> {
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');

  @override
  Widget build(BuildContext context) {
    final _blocHelper = BlocProviderList.of<BlocHelper>(context);
    _blocHelper.tabChange(0);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: CustomDrawer(widget._pageController),
        appBar: AppBar(
          toolbarHeight: 90.0,
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              'Grupos',
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
              Tab(text: 'Meus Grupos'),
              Tab(text: 'Convites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyGroupTab(),
            MyGroupInvitationsTab(),
          ],
        ),
        floatingActionButton: StreamBuilder(
          initialData: 0,
          stream: _blocHelper.selectedTab,
          builder: (context, snapshot) {
            if (snapshot.data == 0)
              return FloatingActionButton(
                child: Icon(Icons.add, color: Theme.of(context).accentColor),
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    Group _group = Group(null, null, "", List(), "");
                    return FormRegisterGroups(_group.id);
                  })).then(
                    (value) => _update(value),
                  );
                },
              );
            return Container();
          },
        ),
      ),
    );
  }

  void _update(Group receiptTransfer) {
    if (receiptTransfer != null) {
      setState(() {
        widget._groups.add(receiptTransfer);
      });
    }
  }
}

class CreateCard extends StatelessWidget {
  final Group _group;

  CreateCard(this._group);

  @override
  Widget build(BuildContext context) {
    int users = _group.users.length;

    return Card(
      child: ListTile(
        title: Text(_group.name),
        subtitle: Text(
          "Usuários Cadastrados $users",
        ),
        leading: IconButton(
          icon: Icon(Icons.assignment_ind),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FormRegisterGroups(_group.id);
            }));
          },
        ),
        // subtitle: Text(_group.value.toString()),
      ),
    );
  }
}
