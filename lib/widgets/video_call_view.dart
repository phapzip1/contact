import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class VideoCallView extends StatelessWidget {
  final RtcEngine engine;
  final String channelName;
  final String receiverName;
  final String receiverAva;
  final bool localCamMute;
  final int remoteUid;
  final bool remoteMute;
  final bool remoteCamMute;
  final String remoteAva;

  VideoCallView({
    required this.engine,
    required this.channelName,
    required this.receiverName,
    required this.receiverAva,
    required this.remoteUid,
    required this.localCamMute,
    required this.remoteMute,
    required this.remoteCamMute,
    required this.remoteAva,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // receiver
        if (remoteUid != -1)
          Positioned.fill(
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: engine,
                canvas: VideoCanvas(uid: remoteUid),
                connection: RtcConnection(channelId: channelName),
              ),
            ),
          ),
        // remote cam off
        if (remoteUid != -1 && remoteCamMute)
          Container(
            decoration: const BoxDecoration(color: Colors.brown),
            child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                backgroundImage: NetworkImage(remoteAva),
                radius: 50,
              ),
            ),
          ),
        // caller
        if (remoteUid != -1 && !localCamMute)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              width: 120,
              height: 200,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
        // preview
        if (remoteUid == -1)
          Positioned.fill(
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        // remote muted
        if (remoteMute && remoteUid != -1)
          const Positioned(
            top: 10,
            left: 10,
            child: Icon(
              Icons.mic_off,
              color: Colors.red,
            ),
          ),
        // modal
        if (remoteUid == -1)
          Container(
            decoration: const BoxDecoration(
              color: Colors.black38,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(receiverAva),
                      radius: 50,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      receiverName,
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
          ),
      ],
    );
  }
}
