import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: validar necessidade desta classe
class InvitationsBloc implements BlocBase {
  @override
  void dispose() {
  }

  InvitationsBloc();

  void saveUserData(Map<String, dynamic> data) async {
    // Map<String, dynamic> data = new Map(String, dynamic);
    await FirebaseFirestore.instance.collection('invitations').add(data);
  }
}
