import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../services/multiplayer_room_service.dart';
import '../models/room_model.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/room_participants_widget.dart';
import '../widgets/loading_dialog.dart';

class RoomLobbyScreen extends StatefulWidget {
  final String roomId;

  const RoomLobbyScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  State<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends State<RoomLobbyScreen> {
  final _roomService = MultiplayerRoomService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    setState(() => _loading = true);
    await context.read<RoomProvider>().joinRoom(widget.roomId);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _leaveRoom() async {
    final confirmed = await _showLeaveDialog();
    if (!confirmed) return;

    final userProvider = context.read<UserProvider>();
    final roomProvider = context.read<RoomProvider>();
    final uid = userProvider.firebaseUser?.uid;
    final room = roomProvider.currentRoom;

    if (uid == null || room == null) return;

    try {
      LoadingDialog.show(context, message: 'Leaving room...');
      await _roomService.leaveRoom(
        roomId: room.id,
        userId: uid,
        ownerId: room.ownerId,
      );
      if (!mounted) return;
      LoadingDialog.hide(context);
      roomProvider.leaveRoom();
      Navigator.popUntil(context, (r) => r.settings.name == AppRoutes.roomHub);
    } catch (e) {
      if (mounted) LoadingDialog.hide(context);
    }
  }

  Future<bool> _showLeaveDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave Room'),
            content: const Text(
                'Are you sure you want to leave? If you are the owner, the room will be deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Leave',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room ID copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final userProvider = context.watch<UserProvider>();
    final room = roomProvider.currentRoom;
    final uid = userProvider.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(room?.name ?? 'Room Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy_outlined),
            tooltip: 'Copy Room ID',
            onPressed: _copyRoomId,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : room == null
              ? _buildRoomNotFound()
              : _buildLobby(context, room, roomProvider, uid),
    );
  }

  Widget _buildRoomNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Room not found', style: AppStyles.heading3),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Go Back',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLobby(BuildContext context, RoomModel room,
      RoomProvider roomProvider, String? uid) {
    final participants = roomProvider.participants;
    final isOwner = room.ownerId == uid;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RoomInfoCard(room: room),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Participants (${participants.length}/${room.maxPlayers})',
                            style: AppStyles.heading3),
                        Icon(
                          participants.length >= room.maxPlayers
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          color: participants.length >= room.maxPlayers
                              ? AppColors.error
                              : AppColors.success,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RoomParticipantsWidget(
                      participants: participants,
                      ownerId: room.ownerId,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Start Rolling',
              icon: Icons.casino_rounded,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.diceRolling,
                arguments: {'roomId': widget.roomId},
              ),
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: isOwner ? 'Delete Room' : 'Leave Room',
              icon: Icons.exit_to_app,
              variant: CustomButtonVariant.danger,
              onPressed: _leaveRoom,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomInfoCard extends StatelessWidget {
  final RoomModel room;

  const _RoomInfoCard({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.name, style: AppStyles.heading2),
            if (room.description != null && room.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(room.description!, style: AppStyles.bodySmall),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Owner: ${room.ownerName}',
                    style: AppStyles.bodySmall),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Max ${room.maxPlayers}', style: AppStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.key_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'ID: ${room.id}',
                    style: AppStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
