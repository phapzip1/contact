import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// firebase
import '../firebase/firestore_methods.dart';

// models
import '../models/call.dart';

// widgets
import '../widgets/video_call_view.dart';
import '../widgets/video_call_panel.dart';
import '../widgets/video_call_picking.dart';

class VideoCallScreen extends StatefulWidget {
  final Call call;
  const VideoCallScreen(this.call, {super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RtcEngine _engine = createAgoraRtcEngine();
  int _remoteUid = -1;

  // local device
  bool _micMute = false;
  bool _camMute = false;

  // remote device;
  bool _rMicMute = false;
  bool _rCamMute = false;

  Future<void> _toggleCam() async {
    await _engine.muteLocalVideoStream(!_camMute);
    setState(() {
      _camMute = !_camMute;
    });
  }

  Future<void> _toggleMic() async {
    await _engine.muteLocalAudioStream(!_micMute);
    setState(() {
      _micMute = !_micMute;
    });
  }

  Future<void> _swichCam() async {
    await _engine.switchCamera();
    await _join();
  }

  Future<void> _endCall() async {
    await FirestoreMethods.getInstance().endCall(widget.call);
  }

  Future<void> _setupVideoCall() async {
    await [Permission.microphone, Permission.camera].request();

    // init engine
    await _engine.initialize(const RtcEngineContext(
      appId: "ad0f1717b7c846f7a6fc435c99929ea7",
    ));

    await _engine.enableVideo();

    _engine.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (connection, remoteUid, elapsed) {
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserMuteAudio: (connection, remoteUid, muted) {
        //ignore: avoid_print
        print("Remote mic mute: $muted");
        setState(() {
          _rMicMute = muted;
        });
      },
      onUserMuteVideo: (connection, remoteUid, muted) {
        //ignore: avoid_print
        print("Remote cam mute: $muted");
        setState(() {
          _rCamMute = muted;
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
    _setupVideoCall();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _engine.stopPreview();
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _remoteUid == -1 && !widget.call.caller
            ? VideoCallPicking(
                call: widget.call,
                answerFn: () {
                  _join();
                },
              )
            : Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: VideoCallView(
                      engine: _engine,
                      remoteUid: _remoteUid,
                      channelName: widget.call.callerName,
                      receiverName: widget.call.receiverName,
                      receiverAva: widget.call.receiverAva,
                      localCamMute: _camMute,
                      remoteAva: widget.call.caller ? widget.call.receiverAva : widget.call.callerAva,
                      remoteMute: _rMicMute,
                      remoteCamMute: _rCamMute,
                    ),
                  ),
                  // panel
                  Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: VideoCallPanel(
                        cam: !_camMute,
                        mic: !_micMute,
                        toggleMicFn: _toggleMic,
                        toggleCamFn: _toggleCam,
                        switchCamFn: _swichCam,
                        endCallFn: _endCall,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
