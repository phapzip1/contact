import 'dart:io';

import 'package:flutter/material.dart';

// widgets
import '../widgets/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this._submitFn);
  final Function(String email, String? username, String password, File? avatar, bool isLogin)
      _submitFn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formkey = GlobalKey<FormState>();
  String _username = "";
  String _email = "";
  String _password = "";
  File? _userCover;

  bool _isLogin = true;

  void _pickImage(File image) {
    _userCover = image;
  }

  void _submit() {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_userCover == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please pick an image"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (isValid) {
      _formkey.currentState?.save();
      widget._submitFn(_email.trim(), _username.trim(), _password, _userCover, _isLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (!_isLogin)
                  UserImagePicker(_pickImage),
                  TextFormField(
                    key: const ValueKey("email"),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                    ),
                    validator: (text) {
                      if (text != null) {
                        if (text.isEmpty ||
                            !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(text)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      }
                      return "Please enter a valid email address";
                    },
                    onSaved: (text) {
                      _email = text!;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: const ValueKey("username"),
                      decoration: const InputDecoration(
                        labelText: "Username",
                      ),
                      validator: (text) {
                        if (text != null) {
                          if (text.isEmpty || text.length < 4) {
                            return "Username must be at least 4 characters long";
                          }
                          return null;
                        }
                        return "Username must be at least 4 characters long";
                      },
                      onSaved: (text) {
                        _username = text!;
                      },
                    ),
                  TextFormField(
                    key: const ValueKey("password"),
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                    obscureText: true,
                    validator: (text) {
                      if (text != null) {
                        if (text.isEmpty || text.length < 7) {
                          return "Password must be at least 7 characters long";
                        }
                        return null;
                      }
                      return "Password must be at least 7 characters long";
                    },
                    onSaved: (text) {
                      _password = text!;
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isLogin ? "Login" : "Signup"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin
                        ? "Create new account"
                        : "I already have an account"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
