import 'dart:io';

import 'package:flutter/material.dart';

// widgets
import '../widgets/auth_form.dart';

// firebase
import '../firebase/auth_methods.dart';

class AuthScreen extends StatelessWidget {

  void _submitFn(String email, String? username, String password, File? avatar, bool isLogin) async {
    if (isLogin) {
      await AuthMethods.getInstance().login(email, password);
    } else {
      await AuthMethods.getInstance().register(username!, password, email, avatar!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthForm(_submitFn),
    );
  }
}

