import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/multiplayer_room_service.dart';
import '../models/room_model.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';

class RoomHubScreen extends StatefulWidget {
  const RoomHubScreen({Key? key}) : super(key: key);

  @override
  State<RoomHubScreen> createState() => _RoomHubScreenState();
}

class _RoomHubScreenState extends State<RoomHubScreen> {
  final _roomService = MultiplayerRoomService();
  List<RoomModel> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
    try {
      final rooms = await _roomService.listActiveRooms();
      if (mounted) setState(() => _rooms = rooms);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final uid = userProvider.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRooms,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Create Room',
                      icon: Icons.add,
                      onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.createRoom)
                          .then((_) => _loadRooms()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Join Room',
                      icon: Icons.login,
                      variant: CustomButtonVariant.outlined,
                      onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.joinRoom)
                          .then((_) => _loadRooms()),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Active Rooms', style: AppStyles.heading3),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _rooms.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _rooms.length,
                          itemBuilder: (_, i) => _RoomCard(
                            room: _rooms[i],
                            currentUserId: uid,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.roomLobby,
                                arguments: {'roomId': _rooms[i].id},
                              ).then((_) => _loadRooms());
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.meeting_room_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('No active rooms', style: AppStyles.heading3),
          const SizedBox(height: 8),
          Text('Create one to get started!', style: AppStyles.bodySmall),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final String? currentUserId;
  final VoidCallback onTap;

  const _RoomCard({
    Key? key,
    required this.room,
    required this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOwner = room.ownerId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(room.name, style: AppStyles.heading3),
                  ),
                  if (isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Owner',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (room.description != null && room.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(room.description!, style: AppStyles.bodySmall),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Max ${room.maxPlayers} players',
                    style: AppStyles.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.shield_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Owner: ${room.ownerName}',
                      style: AppStyles.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
