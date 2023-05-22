import 'package:flutter/material.dart';

// firebase
import '../firebase/firestore_methods.dart';
import '../firebase/auth_methods.dart';

// models
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: StreamBuilder(
            stream: FirestoreMethods.getInstance().currentUserStream(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData) {
                if (userSnapshot.data!.data() == null) {
                  return const Placeholder();
                }
                final user = MyUser.fromMap(userSnapshot.data!.id, userSnapshot.data!.data()!);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: user == null ? Colors.blue : null,
                      backgroundImage: user != null ? NetworkImage(user.coverUrl) : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (user != null) Text(user.username),
                    const SizedBox(
                      height: 10,
                    ),
                    if (user != null) Text(user.email),
                  ],
                );
              } 
              return const Placeholder();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AuthMethods.getInstance().signOut();
          Navigator.of(context).pushReplacementNamed("/");
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
