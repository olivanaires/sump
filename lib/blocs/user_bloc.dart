import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sumpapp/model/status.dart';
import 'package:sumpapp/model/user_model.dart';

class UserBloc implements BlocBase {
  static const USER_TYPE_DEFAULT = 'DEFAULT';
  static const USER_TYPE_GOOGLE = 'GOOGLE';

  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _isLoggedIn = BehaviorSubject<bool>(seedValue: false);
  final _isLoading = BehaviorSubject<bool>(seedValue: false);
  final _userData = BehaviorSubject<Map<String, dynamic>>(seedValue: null);
  final StreamController _search = StreamController();

  Stream<bool> get isLoggedIn => _isLoggedIn.stream;

  Stream<bool> get isLoading => _isLoading.stream;

  Stream<Map<String, dynamic>> get userData => _userData.stream;

  Sink get inSearch => _search.sink;

  User firebaseUser;

  UserBloc();

  @override
  void dispose() {
    _isLoggedIn.close();
    _isLoading.close();
    _userData.close();
    _search.close();
  }

  void signUp(
      {@required Map<String, dynamic> userData,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail(error)}) async {
    _isLoading.sink.add(true);

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userData['email']).get();
    if (query.docs.length > 0) {
      onFail('Já existe um cadastro com esse e-mail.');
      _isLoading.sink.add(false);
      return;
    }

    _auth.createUserWithEmailAndPassword(email: userData['email'], password: pass).then((userCredential) async {
      firebaseUser = userCredential.user;

      userData.remove('uid');
      await _saveUserData(firebaseUser.uid, USER_TYPE_DEFAULT, userData);

      onSuccess();
      _isLoggedIn.sink.add(true);
      _isLoading.sink.add(false);
    }).catchError((e) {
      onFail(e.toString());
      _isLoggedIn.sink.add(false);
      _isLoading.sink.add(false);
    });
  }

  void signIn(
      {@required String email,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) async {
    _isLoading.sink.add(true);

    _auth.signInWithEmailAndPassword(email: email, password: pass).then((userCredential) async {
      firebaseUser = userCredential.user;

      await _saveUserDeviceToken();

      onSuccess();
      _isLoggedIn.sink.add(true);
      _isLoading.sink.add(false);
    }).catchError((e) {
      onFail();
      _isLoggedIn.sink.add(false);
      _isLoading.sink.add(false);
    });
  }

  Future<AuthCredential> _googleAuthCredential() async {
    final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication authentication = await googleSignInAccount.authentication;
    final AuthCredential credential =
        GoogleAuthProvider.credential(idToken: authentication.idToken, accessToken: authentication.accessToken);
    return credential;
  }

  void signUpWithGoogle({@required VoidCallback onSuccess, @required VoidCallback onFail(error)}) async {
    try {
      _isLoading.sink.add(true);

      final AuthCredential credential = await _googleAuthCredential();

      _auth.signInWithCredential(credential).then((userCredential) async {
        firebaseUser = userCredential.user;

        await _saveUser(USER_TYPE_GOOGLE);

        onSuccess();
        _isLoggedIn.sink.add(true);
        _isLoading.sink.add(false);
      });
    } catch (error) {
      onFail('Falha ao registra-se');
      _isLoggedIn.sink.add(false);
      _isLoading.sink.add(false);
    }
  }

  void signInWithGoogle({@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    try {
      _isLoading.sink.add(true);

      final AuthCredential credential = await _googleAuthCredential();

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      firebaseUser = userCredential.user;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      if (snapshot.data() == null) {
        await _saveUser(USER_TYPE_GOOGLE);
      }

      onSuccess();
      _isLoggedIn.sink.add(true);
      _isLoading.sink.add(false);
    } catch (error) {
      onFail();
      _isLoggedIn.sink.add(false);
      _isLoading.sink.add(false);
    }
  }

  Future _saveUser(String type) async {
    Map<String, dynamic> userData = {
      'email': firebaseUser.email,
      'name': firebaseUser.displayName,
      'valid': false,
    };

    if (firebaseUser.photoURL != null && firebaseUser.photoURL.isNotEmpty) {
      userData['profileImgURL'] = firebaseUser.photoURL;
    }

    await _saveUserData(firebaseUser.uid, type, userData);
    await _saveUserDeviceToken();
  }

  void signOut() async {
    await _auth.signOut();
    firebaseUser = null;
    _userData.sink.add(null);
    _isLoggedIn.sink.add(false);
    _isLoading.sink.add(false);
  }

  void updateProfile(Map<String, dynamic> userData, VoidCallback onSuccess, VoidCallback onFail) async {
    userData.remove('uid');
    _updateUserData(userData).then((value) {
      onSuccess();
    }).catchError((onError) => onFail());
  }

  void updateImgProfile(File profileImg) async {
    updateImgValidateProfile(profileImg, 'profileImgURL');
  }

  void updateImgValidateProfile(File profileImg, String key) async {
    Reference reference = FirebaseStorage.instance.ref().child(DateTime.now().millisecondsSinceEpoch.toString());

    UploadTask task = reference.putFile(profileImg);
    task.whenComplete(() async {
      try {
        String url = await reference.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({key: url});
      } catch (onError) {
        print("Error");
      }
    });
  }

  void changePass(String newPassword) async {
    User user = _auth.currentUser;
    await user.updatePassword(newPassword);
  }

  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<Null> _saveUserData(String uid, String type, Map<String, dynamic> userData) async {
    userData['type'] = type;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
    _userData.sink.add(userData);
    _saveUserDeviceToken();
  }

  Future<Null> _updateUserData(Map<String, dynamic> userData) async {
    userData.remove('profileImgURL');
    await FirebaseFirestore.instance.collection('users').doc(this.firebaseUser.uid).update(userData);
  }

  Future<UserModel> isExistsUser(String email) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

    if (snapshot.docs.length > 0) {
      DocumentSnapshot doc = snapshot.docs[0];
      return UserModel.fromDocument(doc);
    }
    return new UserModel();
  }

  void updateGroups(groupUserId, grouId, status) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('groups').doc(groupUserId).get();
    var users = [...snapshot.get('users')];

    switch (status) {
      case STATUS.APPROVED:
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .collection("groups")
            .doc(groupUserId)
            .update({'status': STATUS.APPROVED});

        users.forEach((user) {
          if (user['userId'] == firebaseUser.uid) user['status'] = STATUS.APPROVED;
        });
        break;

      case STATUS.OFF:
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .collection("groups")
            .doc(groupUserId)
            .delete();

        users.removeWhere((user) => user['userId'] == firebaseUser.uid);
        break;
    }

    await FirebaseFirestore.instance.collection('groups').doc(groupUserId).update({'users': users});
  }

  Stream<QuerySnapshot> loadInvitationsUsers() {
    Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .collection("groups")
        .where("status", isEqualTo: STATUS.AWAITING)
        .snapshots();
    return snapshot;
  }

  Stream<DocumentSnapshot> loadUser() {
    if (_auth.currentUser == null) return Stream.empty();

    firebaseUser = _auth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then((docUser) => _userData.sink.add(docUser.data()));

    return FirebaseFirestore.instance.collection('users').doc(_auth.currentUser.uid).snapshots();
  }

  Future<void> _saveUserDeviceToken() async {
    final token = await FirebaseMessaging().getToken();
    await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).collection('tokens').doc(token).set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
    });
  }
}
