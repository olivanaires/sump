import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sumpapp/pages/review_page.dart';

class HospitalReviewsPage extends StatelessWidget {
  final String hospitalUid;
  final String hospitalName;

  HospitalReviewsPage({Key key, this.hospitalUid, this.hospitalName}) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 90.0,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            'Hospital $hospitalName',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Theme.of(context).accentColor),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReviewPage(hospitalUid: hospitalUid)));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospitals')
            .document(hospitalUid)
            .collection('reviews')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.docs != null) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                var rating = snapshot.data.docs[index]['rating'];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Médico: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(child: Text(snapshot.data.docs[index]['doctor']['name'])),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text('Data: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format((snapshot.data.docs[index]['date'] as Timestamp).toDate()),
                              ),
                            ),
                            Text('Avaliação: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Row(
                                children: [
                                  rating >= 1 ? Icon(Icons.star, size: 16.0) : Container(),
                                  rating >= 2 ? Icon(Icons.star, size: 16.0) : Container(),
                                  rating >= 3 ? Icon(Icons.star, size: 16.0) : Container(),
                                  rating >= 4 ? Icon(Icons.star, size: 16.0) : Container(),
                                  rating == 5 ? Icon(Icons.star, size: 16.0) : Container(),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text('Comentário:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(snapshot.data.docs[index]['comment'])
                      ],
                    ),
                  ),
                );
              },
            );
          } else
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor)]),
            );
        },
      ),
    );
  }
}
