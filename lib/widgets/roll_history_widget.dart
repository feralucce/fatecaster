import 'package:flutter/material.dart';
import '../models/multiplayer_roll.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'roll_display_widget.dart';

enum RollSortOrder { newest, oldest, highest, lowest }

class RollHistoryWidget extends StatefulWidget {
  final List<MultiplayerRoll> rolls;
  final String? filterUserId;
  final VoidCallback? onClear;

  const RollHistoryWidget({
    Key? key,
    required this.rolls,
    this.filterUserId,
    this.onClear,
  }) : super(key: key);

  @override
  State<RollHistoryWidget> createState() => _RollHistoryWidgetState();
}

class _RollHistoryWidgetState extends State<RollHistoryWidget> {
  RollSortOrder _sortOrder = RollSortOrder.newest;
  String? _filterUser;

  List<MultiplayerRoll> get _sorted {
    var list = widget.rolls.toList();
    if (_filterUser != null) {
      list = list.where((r) => r.userId == _filterUser).toList();
    }
    switch (_sortOrder) {
      case RollSortOrder.newest:
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case RollSortOrder.oldest:
        list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case RollSortOrder.highest:
        list.sort((a, b) => b.total.compareTo(a.total));
        break;
      case RollSortOrder.lowest:
        list.sort((a, b) => a.total.compareTo(b.total));
        break;
    }
    return list;
  }

  List<String> get _uniqueUsers {
    return widget.rolls.map((r) => r.userId).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final rolls = _sorted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildControls(),
        const SizedBox(height: 8),
        if (rolls.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No rolls yet',
                style: AppStyles.bodySmall,
              ),
            ),
          )
        else
          ...rolls.map((r) => RollDisplayWidget(roll: r, compact: true)),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SortChip(
                  label: 'Newest',
                  selected: _sortOrder == RollSortOrder.newest,
                  onTap: () =>
                      setState(() => _sortOrder = RollSortOrder.newest),
                ),
                _SortChip(
                  label: 'Oldest',
                  selected: _sortOrder == RollSortOrder.oldest,
                  onTap: () =>
                      setState(() => _sortOrder = RollSortOrder.oldest),
                ),
                _SortChip(
                  label: 'Highest',
                  selected: _sortOrder == RollSortOrder.highest,
                  onTap: () =>
                      setState(() => _sortOrder = RollSortOrder.highest),
                ),
                _SortChip(
                  label: 'Lowest',
                  selected: _sortOrder == RollSortOrder.lowest,
                  onTap: () =>
                      setState(() => _sortOrder = RollSortOrder.lowest),
                ),
                if (_uniqueUsers.length > 1) ...[
                  const SizedBox(width: 8),
                  _SortChip(
                    label: _filterUser == null ? 'All Players' : 'Mine',
                    selected: _filterUser != null,
                    onTap: () => setState(() {
                      _filterUser =
                          _filterUser == null ? widget.filterUserId : null;
                    }),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.onClear != null)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: AppColors.textSecondary),
            tooltip: 'Clear history',
            onPressed: widget.onClear,
          ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                selected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
