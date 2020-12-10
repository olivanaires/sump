import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sumpapp/blocs/user_bloc.dart';

class ReviewPage extends StatefulWidget {
  final String hospitalUid;

  ReviewPage({Key key, this.hospitalUid}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState(hospitalUid);
}

class _ReviewPageState extends State<ReviewPage> {
  final String hospitalUid;

  _ReviewPageState(this.hospitalUid);

  int rating = 0;

  final _commentController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessageKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProviderList.of<UserBloc>(context);

    return ScaffoldMessenger(
      key: _scaffoldMessageKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 90.0,
          title: Text(
            'Adicionar Comentário',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Avaliação: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(rating >= 1 ? Icons.star : Icons.star_border),
                      tooltip: '1',
                      onPressed: () => setState(() => rating = 1),
                    ),
                    IconButton(
                      icon: Icon(rating >= 2 ? Icons.star : Icons.star_border),
                      tooltip: '2',
                      onPressed: () => setState(() => rating = 2),
                    ),
                    IconButton(
                      icon: Icon(rating >= 3 ? Icons.star : Icons.star_border),
                      tooltip: '3',
                      onPressed: () => setState(() => rating = 3),
                    ),
                    IconButton(
                      icon: Icon(rating >= 4 ? Icons.star : Icons.star_border),
                      tooltip: '4',
                      onPressed: () => setState(() => rating = 4),
                    ),
                    IconButton(
                      icon: Icon(rating == 5 ? Icons.star : Icons.star_border),
                      tooltip: '5',
                      onPressed: () => setState(() => rating = 5),
                    ),
                  ],
                ),
                SizedBox(height: 18.0),
                Row(
                  children: [
                    Expanded(
                      child: Text('Comentário: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _commentController,
                        maxLines: 8,
                        maxLength: 200,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(hintText: 'Digite aqui o seu comentário.'),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 36.0),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    child: Text(
                      'Enviar',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).accentColor,
                    onPressed: () async {
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_userBloc.firebaseUser.uid).get();
                      FirebaseFirestore.instance.collection('hospitals').doc(hospitalUid).collection('reviews').add({
                        'comment': _commentController.text,
                        'rating': rating,
                        'date': DateTime.now(),
                        'doctor': {
                          'uid': _userBloc.firebaseUser.uid,
                          'name': userDoc.data()['name'],
                        }
                      }).then((value) {
                        _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
                          content: Text('Comentário enviado com sucesso'),
                          backgroundColor: Theme.of(context).primaryColor,
                          duration: Duration(seconds: 2),
                        ));

                        Future.delayed(Duration(seconds: 2)).then((_) {
                          Navigator.of(context).pop();
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
