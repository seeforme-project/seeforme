import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String token;

  const MeetingScreen({
    super.key,
    required this.meetingId,
    required this.token,
  });

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late Room _room;
  Map<String, Participant> participants = {};
  bool isMicOn = true;
  bool isCamOn = true;

  @override
  void initState() {
    super.initState();

    _room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: "John Doe",
      micEnabled: isMicOn,
      camEnabled: isCamOn,
      defaultCameraIndex: 1,
    );

    setEventListeners();
    _room.join();
  }

  void setEventListeners() {
    _room.on(Events.roomJoined, () {
      print(" Room Joined Successfully");
      setState(() {
        participants = _room.participants;
      });
    });

    _room.on(Events.participantJoined, (Participant participant) {
      setState(() {
        participants.putIfAbsent(participant.id, () => participant);
      });
    });

    _room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(() {
          participants.remove(participantId);
        });
      }
    });

    _room.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'audio') {}
      if (stream.kind == 'video') {}
    });

    _room.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'audio') {}
      if (stream.kind == 'video') {}
    });

    _room.on(Events.roomLeft, () {
      participants.clear();
      Navigator.popUntil(context, (route) => route.isFirst);
    });

    _room.on(Events.error, (error) {
      print("❗️Error connecting to room: ${error['name']} - ${error['message']}");
    });
  }

  @override
  void dispose() {
    _room.leave();
    super.dispose();
  }

  void onToggleMicButtonPressed() {
    if (isMicOn) {
      _room.muteMic();
    } else {
      _room.unmuteMic();
    }
    setState(() {
      isMicOn = !isMicOn;
    });
  }

  void onToggleCameraButtonPressed() {
    if (isCamOn) {
      _room.disableCam();
    } else {
      _room.enableCam();
    }
    setState(() {
      isCamOn = !isCamOn;
    });
  }

  void onLeaveButtonPressed() {
    _room.leave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoSDK Meeting'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants.values.elementAt(index);
                Stream? videoStream;
                try {
                  videoStream = participant.streams.values
                      .firstWhere((stream) => stream.kind == 'video');
                } catch (e) {
                  videoStream = null;
                }

                return videoStream != null
                    ? RTCVideoView(
                  videoStream.renderer as RTCVideoRenderer,
                  objectFit:
                  RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
                    : Container(
                  color: Colors.grey.shade800,
                  child: Center(
                    child: Text(
                      participant.displayName
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 24, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: onToggleMicButtonPressed,
                  icon: Icon(isMicOn ? Icons.mic : Icons.mic_off),
                  tooltip: 'Toggle Mic',
                ),
                IconButton(
                  onPressed: onLeaveButtonPressed,
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  tooltip: 'Leave Meeting',
                ),
                IconButton(
                  onPressed: onToggleCameraButtonPressed,
                  icon: Icon(isCamOn ? Icons.videocam : Icons.videocam_off),
                  tooltip: 'Toggle Camera',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
