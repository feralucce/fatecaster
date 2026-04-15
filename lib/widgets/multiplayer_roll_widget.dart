import 'dart:async';
import 'package:flutter/material.dart';
import '../models/multiplayer_roll.dart';
import '../services/multiplayer_roll_service.dart';

class MultiplayerRollWidget extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final MultiplayerRollService rollService;

  const MultiplayerRollWidget({
    Key? key,
    required this.roomId,
    required this.currentUserId,
    required this.rollService,
  }) : super(key: key);

  @override
  _MultiplayerRollWidgetState createState() => _MultiplayerRollWidgetState();
}

class _MultiplayerRollWidgetState extends State<MultiplayerRollWidget> {
  final List<MultiplayerRoll> _rolls = [];
  late StreamSubscription<MultiplayerRoll> _subscription;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history =
          await widget.rollService.getRollHistory(widget.roomId);
      if (mounted) {
        setState(() {
          _rolls.addAll(history);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }

    _subscription = widget.rollService.listenForRolls(widget.roomId).listen(
      (roll) {
        if (mounted) {
          setState(() {
            // Avoid duplicating rolls already fetched from history.
            final alreadyPresent =
                _rolls.any((r) => r.rollId == roll.rollId);
            if (!alreadyPresent) _rolls.add(roll);
          });
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Live Rolls',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_rolls.isEmpty)
          const Text('No rolls yet. Be the first to roll!')
        else
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _rolls.length,
              itemBuilder: (context, index) {
                final roll =
                    _rolls[_rolls.length - 1 - index];
                final isOwn = roll.userId == widget.currentUserId;
                final total = roll.rollResult['total'];
                final notation = roll.rollResult['notation'] ?? '';
                final timeStr =
                    '${roll.timestamp.hour.toString().padLeft(2, '0')}:'
                    '${roll.timestamp.minute.toString().padLeft(2, '0')}:'
                    '${roll.timestamp.second.toString().padLeft(2, '0')}';

                return Card(
                  color: isOwn
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        isOwn
                            ? 'Me'
                            : roll.userId.length >= 2
                                ? roll.userId.substring(0, 2).toUpperCase()
                                : roll.userId.toUpperCase(),
                      ),
                    ),
                    title: Text(
                      isOwn ? 'You' : roll.userId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$notation → $total'),
                    trailing: Text(timeStr,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
