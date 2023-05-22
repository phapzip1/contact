import 'package:flutter/material.dart';

// models
import '../models/call.dart';

// widgets
import '../widgets/circle_button.dart';

// firebase
import '../firebase/firestore_methods.dart';

class VideoCallPicking extends StatelessWidget {
  final Call call;
  final void Function() answerFn;

  VideoCallPicking({required this.call, required this.answerFn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black26,
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(call.callerAva),
                    radius: 50,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    call.callerName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50, left: 70, right: 70),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleButton(
                    onClick: () {
                      FirestoreMethods.getInstance().endCall(call);
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  CircleButton(
                    onClick: answerFn,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.videocam,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
