import 'package:flutter/material.dart';
import '../models/multiplayer_roll.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class RollDisplayWidget extends StatelessWidget {
  final MultiplayerRoll roll;
  final bool compact;

  const RollDisplayWidget({
    Key? key,
    required this.roll,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(roll.notation, style: AppStyles.heading3),
                Text(
                  roll.total.toString(),
                  style: AppStyles.rollResultSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: roll.individualRolls
                  .map((r) => _DieChip(value: r))
                  .toList(),
            ),
            if (roll.modifier != 0) ...[
              const SizedBox(height: 4),
              Text(
                'Modifier: ${roll.modifier > 0 ? '+' : ''}${roll.modifier}',
                style: AppStyles.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(roll.userName, style: AppStyles.label),
                Text(
                  _formatTime(roll.timestamp),
                  style: AppStyles.bodySmall,
                ),
              ],
            ),
            if (roll.withAdvantage == true)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Advantage',
                    style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            if (roll.withDisadvantage == true)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Disadvantage',
                    style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Row(
        children: [
          Text(roll.notation, style: AppStyles.bodyMedium),
          const SizedBox(width: 8),
          Text(
            '= ${roll.total}',
            style: AppStyles.bodyMedium
                .copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Text(roll.userName, style: AppStyles.bodySmall),
      trailing: Text(_formatTime(roll.timestamp), style: AppStyles.bodySmall),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

class _DieChip extends StatelessWidget {
  final int value;

  const _DieChip({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withOpacity(0.6)),
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
