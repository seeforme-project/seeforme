import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String token;
  final String displayName;

  const MeetingScreen({Key? key, required this.meetingId, required this.token, required this.displayName,})
      : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  Room? room;
  Map<String, Participant> participants = {};

  bool isMicOn = true;
  bool isCamOn = true;

  @override
  void initState() {
    super.initState();
    // Create Room
    room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: isMicOn,
      camEnabled: isCamOn,
      defaultCameraIndex: 1,
    );

    // Subscribe to events
    subscribeToEvents();

    // Join room
    room?.join();
  }

  void subscribeToEvents() {
    room?.on(Events.roomJoined, () {
      setState(() {
        participants[room!.localParticipant.id] = room!.localParticipant;
      });
      subscribeToParticipantEvents(room!.localParticipant);
    });

    room?.on(Events.participantJoined, (Participant participant) {
      setState(() {
        participants[participant.id] = participant;
      });
      subscribeToParticipantEvents(participant);
    });

    room?.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(() {
          participants.remove(participantId);
        });
      }
    });

    room?.on(Events.roomLeft, () {
      participants.clear();
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  void subscribeToParticipantEvents(Participant participant) {
    participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() {});
      }
    });

    participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    room?.leave();
    super.dispose();
  }


  void _onToggleMic() {
    if (isMicOn) {
      room?.muteMic();
    } else {
      room?.unmuteMic();
    }

    setState(() {
      isMicOn = !isMicOn;
    });
  }

  void _onToggleCamera() {
    if (isCamOn) {
      room?.disableCam();
    } else {
      room?.enableCam();
    }
    setState(() {
      isCamOn = !isCamOn;
    });
  }

  void _onLeaveMeeting() {
    room?.leave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting ID: ${widget.meetingId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.meetingId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Meeting ID copied!")),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: participants.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  Participant participant = participants.values.elementAt(index);
                  return ParticipantTile(participant: participant);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _onToggleMic,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: isMicOn ? Colors.blueAccent : Colors.grey[700],
                    ),
                    child: Icon(
                      isMicOn ? Icons.mic : Icons.mic_off,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onLeaveMeeting,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onToggleCamera,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: isCamOn ? Colors.blueAccent : Colors.grey[700],
                    ),
                    child: Icon(
                      isCamOn ? Icons.videocam : Icons.videocam_off,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantTile extends StatelessWidget {
  final Participant participant;
  const ParticipantTile({Key? key, required this.participant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Stream? videoStream;
    try {
      videoStream = participant.streams.values.firstWhere((stream) => stream.kind == 'video');
    } catch (e) {
      videoStream = null;
    }

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.blueGrey.shade800)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: (videoStream != null && videoStream.renderer != null)
            ? RTCVideoView(
          videoStream.renderer!,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        )
            : Center(
          child: Text(
            participant.displayName.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}