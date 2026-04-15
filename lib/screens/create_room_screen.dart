import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/multiplayer_room_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_banner.dart';
import '../widgets/loading_dialog.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _roomService = MultiplayerRoomService();

  int _maxPlayers = 6;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    final userProvider = context.read<UserProvider>();
    final uid = userProvider.firebaseUser?.uid;
    final displayName =
        userProvider.profile?.displayName ?? 'Player';

    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'Not authenticated.';
      });
      return;
    }

    try {
      LoadingDialog.show(context, message: 'Creating room...');
      final roomId = await _roomService.createRoom(
        name: _nameController.text.trim(),
        ownerId: uid,
        ownerName: displayName,
        maxPlayers: _maxPlayers,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );
      if (!mounted) return;
      LoadingDialog.hide(context);
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.roomLobby,
        arguments: {'roomId': roomId},
      );
    } catch (e) {
      if (mounted) LoadingDialog.hide(context);
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Room Details', style: AppStyles.heading3),
                const SizedBox(height: 16),
                ErrorBanner(
                    message: _error,
                    onDismiss: () => setState(() => _error = '')),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Room Name',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Room name is required';
                    if (v.trim().length < 3) return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Max Players', style: AppStyles.heading3),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('$_maxPlayers players',
                        style: AppStyles.bodyLarge),
                    Expanded(
                      child: Slider(
                        value: _maxPlayers.toDouble(),
                        min: 2,
                        max: 20,
                        divisions: 18,
                        label: '$_maxPlayers',
                        onChanged: (v) =>
                            setState(() => _maxPlayers = v.toInt()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Create Room',
                  icon: Icons.add,
                  onPressed: _loading ? null : _create,
                  isLoading: _loading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
