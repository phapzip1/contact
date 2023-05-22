import 'package:call/firebase/firestore_methods.dart';
import 'package:call/screens/video_call_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import './firebase_options.dart';

// screens
import './screens/home_screen.dart';
import './screens/auth_screen.dart';
import './screens/profile_screen.dart';
import './screens/audio_call_screen.dart';

// models
import './models/call.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //ignore: avoid_print
  print("------------------Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((event) {
    //ignore: avoid_print
    print("Foreground: ${event.messageId}");
  });

  final fcmToken = await FirebaseMessaging.instance.getToken();
  //ignore: avoid_print
  print("Token: $fcmToken");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, auth) {
            if (auth.hasData) {
              FirestoreMethods.getInstance().getCallStream().listen(
                (calls) {
                  if (calls.size != 0) {
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (ctx2) {
                          final Call call = Call.fromMap(calls.docs[0].data());
                          if (call.video) {
                            return VideoCallScreen(call);
                          }
                          return AudioCallScreen(call);
                        },
                      ),
                    );
                  }
                },
              );
              return HomeScreen();
            }
            return AuthScreen();
          },
        ),
        routes: {
          "/profile": (ctx) => ProfileScreen(),
        });
  }
}
