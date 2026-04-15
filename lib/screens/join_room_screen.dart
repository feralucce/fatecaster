import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/multiplayer_room_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_banner.dart';
import '../widgets/loading_dialog.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _roomService = MultiplayerRoomService();

  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    final userProvider = context.read<UserProvider>();
    final uid = userProvider.firebaseUser?.uid;
    final displayName = userProvider.profile?.displayName ?? 'Player';
    final avatarUrl = userProvider.profile?.avatarUrl;

    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'Not authenticated.';
      });
      return;
    }

    final roomId = _codeController.text.trim();

    try {
      LoadingDialog.show(context, message: 'Joining room...');
      await _roomService.joinRoom(
        roomId: roomId,
        userId: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
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
      appBar: AppBar(title: const Text('Join Room')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.login_rounded,
                  size: 64,
                  color: Color(0xFF6C3FB5),
                ),
                const SizedBox(height: 16),
                Text('Enter Room Code', style: AppStyles.heading2,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Ask the room owner for their room ID',
                    style: AppStyles.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ErrorBanner(
                    message: _error,
                    onDismiss: () => setState(() => _error = '')),
                TextFormField(
                  controller: _codeController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _join(),
                  decoration: const InputDecoration(
                    labelText: 'Room Code / ID',
                    prefixIcon: Icon(Icons.key_outlined),
                    hintText: 'Paste room ID here',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter a room code';
                    }
                    if (v.trim().length < 4) {
                      return 'Room code is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Join Room',
                  icon: Icons.login,
                  onPressed: _loading ? null : _join,
                  isLoading: _loading,
                  width: double.infinity,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Or browse available rooms',
                  style: AppStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CustomButton(
                  label: 'Browse Rooms',
                  variant: CustomButtonVariant.outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.roomHub);
                  },
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
