import 'package:flutter/material.dart';

/// A small question-mark icon that opens a tooltip popup with contextual help
/// text when tapped.
///
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Text('Room Code'),
///     HelpTooltip(
///       message: 'A 6-character code used to invite friends to your room.',
///     ),
///   ],
/// )
/// ```
class HelpTooltip extends StatelessWidget {
  /// The help text displayed in the tooltip.
  final String message;

  /// Optional icon. Defaults to [Icons.help_outline_rounded].
  final IconData icon;

  /// Icon size.  Defaults to 18.
  final double iconSize;

  const HelpTooltip({
    super.key,
    required this.message,
    this.icon = Icons.help_outline_rounded,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      preferBelow: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onInverseSurface,
        fontSize: 13,
      ),
      child: Semantics(
        label: 'Help: $message',
        button: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pre-built contextual help tooltips
// ---------------------------------------------------------------------------

/// Tooltip explaining the room code format.
class RoomCodeHelpTooltip extends StatelessWidget {
  const RoomCodeHelpTooltip({super.key});

  @override
  Widget build(BuildContext context) => const HelpTooltip(
        message:
            'A 6-character code shared with friends so they can join your room. '
            'Codes contain letters and numbers only.',
      );
}

/// Tooltip explaining dice notation syntax.
class DiceNotationHelpTooltip extends StatelessWidget {
  const DiceNotationHelpTooltip({super.key});

  @override
  Widget build(BuildContext context) => const HelpTooltip(
        message:
            'Dice notation format: [count]d[sides][+/-modifier]\n'
            'Examples: "2d6" (two six-sided dice), "1d20+5" (d20 plus 5), '
            '"3d8-2" (three d8 minus 2).',
      );
}

/// Tooltip explaining advantage / disadvantage.
class AdvantageHelpTooltip extends StatelessWidget {
  const AdvantageHelpTooltip({super.key});

  @override
  Widget build(BuildContext context) => const HelpTooltip(
        message:
            'Advantage: roll twice and keep the higher result.\n'
            'Disadvantage: roll twice and keep the lower result.',
      );
}

/// Tooltip explaining modifier syntax.
class ModifierHelpTooltip extends StatelessWidget {
  const ModifierHelpTooltip({super.key});

  @override
  Widget build(BuildContext context) => const HelpTooltip(
        message:
            'A modifier is added to (or subtracted from) the total dice roll. '
            'Use + for a bonus and - for a penalty. Example: +3 or -2.',
      );
}
