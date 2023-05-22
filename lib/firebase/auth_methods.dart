import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

// user class
import '../models/user.dart';

// helpers
import './firestore_methods.dart';
import './storage_methods.dart';

class AuthMethods {
  static AuthMethods? _instance;
  FirebaseAuth? _auth;

  AuthMethods._() {
    _auth = FirebaseAuth.instance;
  }

  static AuthMethods getInstance() {
    if (_instance == null) {
      _instance = AuthMethods._();
      return _instance!;
    }
    return _instance!;
  }

  // 0: successful
  // error code:
  // -1: invalid email
  // -2: user disabled
  // -3: user not found
  // -4: wrong password
  // -5: unhandled
  Future<int> login(String email, String password) async {
    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          return -1;
        case "user-disabled":
          return -2;
        case "user-not-found":
          return -3;
        case "wrong-password":
          return -4;
      }
    }
    return -5;
  }

  // 0: successful
  // error code:
  // -1: email already in use
  // -2: invalid email
  // -3: operation not allowed
  // -4: weak password
  // -5: username already taken
  // -6: unhandled
  Future<int> register(String username, String password, String email, File cover) async {
    try {
      if (!await FirestoreMethods.getInstance().validateUsername(username)) { 
        return -5;
      }
      final userCre = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCre.user!.uid;
      final imageURL = await StorageMethods.getInstance().uploadImage(cover, "$uid.jpg");
      FirestoreMethods.getInstance().createUser(MyUser(uid, email, username, imageURL));
      return 0;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return -1;
        case "invalid-email":
          return -2;
        case "operation-not-allowed":
          return -3;
        case "weak-password":
          return -4;
      }
    }
      return -6;
  }

  Future<void> signOut() async {
    await _auth!.signOut();
  }
}
