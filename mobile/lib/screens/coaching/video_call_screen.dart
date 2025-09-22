import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// Update the import path below to the correct location of session_service.dart
import '../../../services/session_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String coachId;
  const VideoCallScreen({super.key, required this.coachId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _sessionService = SessionService();
  late RtcEngine _engine;
  int? _remoteUid;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    final session = await _sessionService.createSession(widget.coachId);

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "YOUR_AGORA_APP_ID", // Replace with real ID
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int uid) {
          setState(() => _joined = true);
        },
        onUserJoined: (_, uid, __) {
          setState(() => _remoteUid = uid);
        },
        onUserOffline: (_, __, ___) {
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.joinChannel(
      token: session['token'],
      channelId: session['channelName'],
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Live Session"),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Center(
        child: _joined
            ? _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: const RtcConnection(channelId: "test"),
                    ),
                  )
                : Text("Waiting for coach...", style: TextStyle(color: green))
            : const CircularProgressIndicator(),
      ),
    );
  }
}
