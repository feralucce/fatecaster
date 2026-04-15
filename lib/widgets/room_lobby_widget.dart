import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../models/room_participant.dart';
import '../services/multiplayer_room_service.dart';

class RoomLobbyWidget extends StatefulWidget {
  final RoomModel room;
  final String currentUserId;
  final MultiplayerRoomService roomService;
  final VoidCallback? onLeaveRoom;
  final VoidCallback? onStartRolling;

  const RoomLobbyWidget({
    Key? key,
    required this.room,
    required this.currentUserId,
    required this.roomService,
    this.onLeaveRoom,
    this.onStartRolling,
  }) : super(key: key);

  @override
  _RoomLobbyWidgetState createState() => _RoomLobbyWidgetState();
}

class _RoomLobbyWidgetState extends State<RoomLobbyWidget> {
  List<RoomParticipant> _participants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      final participants =
          await widget.roomService.getRoomParticipants(widget.room.roomId);
      if (mounted) {
        setState(() {
          _participants = participants;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leaveRoom() async {
    // MultiplayerRoomService.leaveRoom deletes the entire room when called by
    // the owner, or removes only the participant entry for regular members.
    await widget.roomService.leaveRoom(widget.room.roomId);
    widget.onLeaveRoom?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.room.ownerId == widget.currentUserId;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Room Lobby',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Room ID: ${widget.room.roomId}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
              'Players: ${_participants.length} / ${widget.room.maxPlayers}'),
          const Divider(height: 24),
          Text('Participants',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_participants.isEmpty)
            const Text('No participants yet.')
          else
            Expanded(
              child: ListView.builder(
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final p = _participants[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(p.username),
                    trailing: p.userId == widget.room.ownerId
                        ? const Chip(label: Text('Owner'))
                        : null,
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _leaveRoom,
                  child:
                      Text(isOwner ? 'Delete Room' : 'Leave Room'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onStartRolling,
                  child: const Text('Start Rolling'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
