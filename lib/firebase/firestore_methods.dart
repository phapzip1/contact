import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// constants
import '../constants/string.dart';

// models
import '../models/call.dart';
import '../models/user.dart';

class FirestoreMethods {
  static FirestoreMethods? _instance;
  FirebaseFirestore? _firestore;

  FirestoreMethods._() {
    _firestore = FirebaseFirestore.instance;
  }

  static FirestoreMethods getInstance() {
    if (_instance == null) {
      _instance = FirestoreMethods._();
      return _instance!;
    }
    return _instance!;
  }

  Future<bool> validateUsername(String username) async {
    final querySnapshot = await _firestore!.collection(USER_COLLECTION).where("username", isEqualTo: username).get();
    return querySnapshot.size == 0;
  }

  Future<MyUser?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await _firestore!.collection(USER_COLLECTION).doc(user.uid).get();
      return MyUser(
        docSnapshot.id,
        docSnapshot["email"],
        docSnapshot["username"],
        docSnapshot["coverUrl"],
      );
    }
    return null;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> currentUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    return _firestore!.collection(USER_COLLECTION).doc(user!.uid).snapshots();
  }

  // 0: successful
  // error code
  // -1: username had been taken
  Future<int> createUser(MyUser user) async {
    await _firestore!.collection(USER_COLLECTION).doc(user.uid).set({
      "email": user.email,
      "username": user.username,
      "coverUrl": user.coverUrl,
    });
    return 0;
  }

  Future<MyUser?> getUserByEmail(String email) async {
    final querySnapshot = await _firestore!.collection(USER_COLLECTION).where("email", isEqualTo: email).get();
    if (querySnapshot.size == 0) {
      return null;
    }
    return MyUser(
      querySnapshot.docs[0]["id"],
      querySnapshot.docs[0]["email"],
      querySnapshot.docs[0]["username"],
      querySnapshot.docs[0]["coverUrl"],
    );
  }

  Future<MyUser?> getUserByUsername(String username) async {
    final querySnapshot = await _firestore!.collection(USER_COLLECTION).where("username", isEqualTo: username).get();
    if (querySnapshot.size == 0) {
      return null;
    }
    return MyUser(
      querySnapshot.docs[0]["id"],
      querySnapshot.docs[0]["email"],
      querySnapshot.docs[0]["username"],
      querySnapshot.docs[0]["coverUrl"],
    );
  }

  // 0: successfully
  // -1: user not found
  // -2: try adding your self
  Future<int> addFriend(String username) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final friend = await _firestore!.collection(USER_COLLECTION).where("username", isEqualTo: username).get();
    if (friend.size == 0) {
      return -1;
    }
    if (friend.docs[0].id == uid) {
      return -2;
    }
    await _firestore!.collection(USER_COLLECTION).doc(uid).collection("friends").doc(friend.docs[0].id).set({"addDate": DateTime.now().toString()});
    await _firestore!.collection(USER_COLLECTION).doc(friend.docs[0].id).collection("friends").doc(uid).set({"addDate": DateTime.now().toString()});
    return 0;
  }

  Future<List<MyUser>> getFriends() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final friends = await _firestore!.collection(USER_COLLECTION).doc(uid).collection("friends").get();
    final result = <MyUser>[];

    for (var i = 0; i < friends.size; i++) {
      final user = await _firestore!.collection(USER_COLLECTION).doc(friends.docs[i].id).get();
      result.add(MyUser(friends.docs[i].id, user["email"], user["username"], user["coverUrl"]));
    }
    return result;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCallStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore!.collection(USER_COLLECTION).doc(uid).collection("call").snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDialStream(String callId) {
    return _firestore!.collection(CALL_COLLECTION).doc(callId).snapshots();
  }

  Future<int> makeCall(Call call) async {
    final callSnapshot = await _firestore!.collection(USER_COLLECTION).doc(call.callerId).collection("call").doc("incoming_call").get();
    if (callSnapshot.exists) {
      return -1;
    }

    final response = await http.get(Uri.parse("https://sea-lion-app-xwbmg.ondigitalocean.app/rtc/${call.callerName}/publisher/uid/0"));
    final String token = (json.decode(response.body) as Map<String, dynamic>)["rtcToken"];
    call.token = token;

    call.caller = true;
    await _firestore!.collection(USER_COLLECTION).doc(call.callerId).collection("call").doc("incoming_call").set(Call.toMap(call));

    call.caller = false;
    await _firestore!.collection(USER_COLLECTION).doc(call.receiverId).collection("call").doc("incoming_call").set(Call.toMap(call));

    return 0;
  }

  Future<bool> endCall(Call call) async {
    try {
      await _firestore!.collection(USER_COLLECTION).doc(call.callerId).collection("call").doc("incoming_call").delete();
      await _firestore!.collection(USER_COLLECTION).doc(call.receiverId).collection("call").doc("incoming_call").delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
