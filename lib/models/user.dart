import 'package:firebase_auth/firebase_auth.dart';

class MyUser {
  late String uid;
  late String email;
  late String username;
  late String coverUrl;

  MyUser(this.uid, this.email, this.username, this.coverUrl);
  MyUser.fromMap(String uid, Map<String, dynamic> user) {
    this.uid = uid;
    this.email = user["email"];
    this.username = user["username"];
    this.coverUrl = user["coverUrl"];
  }
}
