import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class FavoritHospitalBloc implements BlocBase {
  List<String> _favorites = <String>[];

  final _favController = BehaviorSubject<List<String>>();

  Stream<List<String>> get outFav => _favController.stream;

  FavoritHospitalBloc(userUid) {
    if (userUid != null)
      FirebaseFirestore.instance.collection('users').doc(userUid).collection('favHospital').get().then((doc) {
        _favorites = doc.docs.map((e) => (e['uid'] as String)).toList();
        _favController.add(_favorites);
      });
  }

  void toggleHospital(String userUid, String hospitalUid) async {
    if (userUid == null || hospitalUid == null) return;

    if (_favorites.contains(hospitalUid)) {
      _favorites.remove(hospitalUid);
      await FirebaseFirestore.instance.collection('users').doc(userUid).collection('favHospital').doc(hospitalUid).delete();
    } else {
      _favorites.add(hospitalUid);
      await FirebaseFirestore.instance.collection('users').doc(userUid).collection('favHospital').doc(hospitalUid).set({'uid': hospitalUid});
    }

    _favController.sink.add(_favorites);
  }

  @override
  void dispose() {
    _favController.close();
  }
}
