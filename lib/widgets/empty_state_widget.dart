import 'package:flutter/material.dart';

/// Displays a friendly empty-state illustration with a title, optional
/// subtitle, and an optional call-to-action button.
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.meeting_room_outlined,
///   title: 'No Rooms Yet',
///   subtitle: 'Create a room to roll dice with your friends.',
///   actionLabel: 'Create Room',
///   onAction: () => Navigator.pushNamed(context, '/create-room'),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// The icon displayed at the top of the empty state.
  final IconData icon;

  /// Short title describing what is empty.
  final String title;

  /// Optional additional description.
  final String? subtitle;

  /// Label for the optional CTA button. Button is hidden when `null`.
  final String? actionLabel;

  /// Callback for the optional CTA button.
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  // ---------------------------------------------------------------------------
  // Convenience constructors
  // ---------------------------------------------------------------------------

  /// Empty state for a room list.
  const EmptyStateWidget.roomList({
    super.key,
    VoidCallback? onCreateRoom,
  })  : icon = Icons.meeting_room_outlined,
        title = 'No Rooms Yet',
        subtitle = 'Create a room to roll dice with friends.',
        actionLabel = 'Create Room',
        onAction = onCreateRoom;

  /// Empty state for roll history.
  const EmptyStateWidget.rollHistory({
    super.key,
    VoidCallback? onRollDice,
  })  : icon = Icons.casino_outlined,
        title = 'No Rolls Yet',
        subtitle = 'Roll some dice to see your history here.',
        actionLabel = 'Roll Dice',
        onAction = onRollDice;

  /// Empty state for participants list.
  const EmptyStateWidget.participants({
    super.key,
    VoidCallback? onInvite,
  })  : icon = Icons.group_outlined,
        title = 'No Participants Yet',
        subtitle = 'Share the room code to invite friends.',
        actionLabel = 'Copy Room Code',
        onAction = onInvite;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceVariant.withOpacity(0.6),
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
