import 'package:flutter/material.dart';
import '../services/multiplayer_room_service.dart';

class JoinRoomWidget extends StatefulWidget {
  final MultiplayerRoomService roomService;
  final void Function(String roomId)? onRoomJoined;

  const JoinRoomWidget({
    Key? key,
    required this.roomService,
    this.onRoomJoined,
  }) : super(key: key);

  @override
  _JoinRoomWidgetState createState() => _JoinRoomWidgetState();
}

class _JoinRoomWidgetState extends State<JoinRoomWidget> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await widget.roomService.joinRoom(_roomIdController.text.trim());
      widget.onRoomJoined?.call(_roomIdController.text.trim());
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Join Room',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomIdController,
              decoration: const InputDecoration(labelText: 'Room code / ID'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Enter a room ID' : null,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _joinRoom,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }
}
