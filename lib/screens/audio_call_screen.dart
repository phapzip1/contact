import 'dart:math' as math;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// models
import '../models/call.dart';

// widgets
import '../widgets/circle_button.dart';

// firebase
import '../firebase/firestore_methods.dart';

class AudioCallScreen extends StatefulWidget {
  final Call call;

  const AudioCallScreen(this.call, {super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final RtcEngine _engine = createAgoraRtcEngine();
  final Color _bgc = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  bool _mute = false;
  bool _remoteMute = false;
  int _remoteUid = -1;

  Future<void> _toggleMic() async {
    await _engine.muteLocalAudioStream(!_mute);
    setState(() {
      _mute = !_mute;
    });
  }

  Future<void> _endCall() async {
    await FirestoreMethods.getInstance().endCall(widget.call);
  }

  Future<void> _setupAudioCall() async {
    await [Permission.microphone].request();

    // init engine
    await _engine.initialize(const RtcEngineContext(
      appId: "ad0f1717b7c846f7a6fc435c99929ea7",
    ));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (connection, remoteUid, elapsed) {
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserMuteAudio: (connection, remoteUid, muted) {
        setState(() {
          _remoteMute = muted;
        });
      },
      onLeaveChannel: (connection, stats) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    ));

    if (widget.call.caller) {
      _join();
    }
  }

  Future<void> _join() async {
    await _engine.startPreview();

    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await _engine.joinChannel(
      token: widget.call.token,
      channelId: widget.call.callerName,
      options: options,
      uid: 0,
    );
  }

  void leave() async {
    await _engine.stopPreview();
    await _engine.leaveChannel();
  }

  @override
  void initState() {
    super.initState();
    FirestoreMethods.getInstance().getCallStream().listen(
      (call) {
        if (!widget.call.caller && _remoteUid == -1 && call.size == 0) {
          if (mounted) {
            Navigator.of(context).pop();
          }
          return;
        }
        if (call.size == 0) {
          leave();
          return;
        }
      },
    );
    _setupAudioCall();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCaller = widget.call.caller;
    final String remoteAva = isCaller ? widget.call.receiverAva : widget.call.callerAva;
    final String remoteName = isCaller ? widget.call.receiverName : widget.call.receiverName;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: _bgc,
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
                      backgroundImage: NetworkImage(remoteAva),
                      radius: 50,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      remoteName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
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
                  mainAxisAlignment: _remoteUid == -1 && isCaller ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // caller waiting
                    if (_remoteUid == -1 && isCaller)
                      CircleButton(
                        onClick: _endCall,
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),

                    // receiver waiting
                    if (_remoteUid == -1 && !isCaller)
                      CircleButton(
                        onClick: () {
                          FirestoreMethods.getInstance().endCall(widget.call);
                        },
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),

                    // receiver waiting
                    if (_remoteUid == -1 && !isCaller)
                      CircleButton(
                        onClick: _join,
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.call,
                          color: Colors.white,
                        ),
                      ),
                    // calling
                    if (_remoteUid != -1)
                      CircleButton(
                        onClick: _toggleMic,
                        backgroundColor: Colors.black45,
                        child: Icon(
                          _mute ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    // calling
                    if (_remoteUid != -1)
                      CircleButton(
                        onClick: _endCall,
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_remoteMute)
              const Positioned(
                top: 10,
                left: 10,
                child: Icon(
                  Icons.mic,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
