import 'package:flutter/material.dart';
import '../services/multiplayer_room_service.dart';
import '../models/room_model.dart';

class CreateRoomWidget extends StatefulWidget {
  final MultiplayerRoomService roomService;
  final void Function(RoomModel room)? onRoomCreated;

  const CreateRoomWidget({
    Key? key,
    required this.roomService,
    this.onRoomCreated,
  }) : super(key: key);

  @override
  _CreateRoomWidgetState createState() => _CreateRoomWidgetState();
}

class _CreateRoomWidgetState extends State<CreateRoomWidget> {
  final _formKey = GlobalKey<FormState>();
  int _maxPlayers = 8;
  bool _loading = false;
  String? _errorMessage;

  Future<void> _createRoom() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final room = await widget.roomService.createRoom(maxPlayers: _maxPlayers);
      widget.onRoomCreated?.call(room);
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
            Text('Create Room',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _maxPlayers.toString(),
              decoration:
                  const InputDecoration(labelText: 'Max players (2–20)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null || n < 2 || n > 20) {
                  return 'Enter a number between 2 and 20';
                }
                return null;
              },
              onChanged: (value) {
                final n = int.tryParse(value);
                if (n != null) setState(() => _maxPlayers = n);
              },
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _createRoom,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}
