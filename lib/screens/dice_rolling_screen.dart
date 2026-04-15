import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../services/dice_service.dart';
import '../services/multiplayer_roll_service.dart';
import '../models/multiplayer_roll.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/roll_history_widget.dart';
import '../widgets/room_participants_widget.dart';

class DiceRollingScreen extends StatefulWidget {
  final String? roomId;

  const DiceRollingScreen({Key? key, this.roomId}) : super(key: key);

  @override
  State<DiceRollingScreen> createState() => _DiceRollingScreenState();
}

class _DiceRollingScreenState extends State<DiceRollingScreen>
    with TickerProviderStateMixin {
  final _diceService = DiceService();
  final _rollService = MultiplayerRollService();
  final _countController = TextEditingController(text: '1');
  final _modifierController = TextEditingController(text: '0');

  // Dice selection
  int _selectedSides = 20;
  static const List<int> _diceOptions = [4, 6, 8, 10, 12, 20, 100];

  // Roll mode
  bool _advantage = false;
  bool _disadvantage = false;

  // Result state
  Map<String, dynamic>? _lastResult;
  List<MultiplayerRoll> _localHistory = [];
  bool _rolling = false;

  // Animation
  late AnimationController _resultAnimation;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _resultAnimation = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _resultAnimation, curve: Curves.easeInOut));

    if (widget.roomId != null) {
      _loadRoomHistory();
    }
  }

  @override
  void dispose() {
    _resultAnimation.dispose();
    _countController.dispose();
    _modifierController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomHistory() async {
    if (widget.roomId == null) return;
    final history = await _rollService.getRollHistory(widget.roomId!);
    if (mounted) setState(() => _localHistory = history);
  }

  int get _diceCount {
    final v = int.tryParse(_countController.text) ?? 1;
    return v.clamp(1, 20);
  }

  int get _modifier {
    return int.tryParse(_modifierController.text) ?? 0;
  }

  String get _notation {
    final mod = _modifier;
    final modStr = mod > 0 ? '+$mod' : (mod < 0 ? '$mod' : '');
    return '${_diceCount}d$_selectedSides$modStr';
  }

  void _setMode(bool advantage, bool disadvantage) {
    setState(() {
      _advantage = advantage;
      _disadvantage = disadvantage;
    });
  }

  Future<void> _roll() async {
    setState(() => _rolling = true);
    await Future.delayed(const Duration(milliseconds: 100));

    Map<String, dynamic> result;
    try {
      if (_advantage) {
        result = _diceService.rollWithAdvantage(_notation);
      } else if (_disadvantage) {
        result = _diceService.rollWithDisadvantage(_notation);
      } else {
        result = _diceService.rollDice(_notation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid notation: $e')),
        );
      }
      setState(() => _rolling = false);
      return;
    }

    setState(() {
      _lastResult = result;
      _rolling = false;
    });
    _resultAnimation.forward(from: 0);

    // Record stats
    final userProvider = context.read<UserProvider>();
    await userProvider.recordRoll(result['total'] as int);

    // Share to room if in one
    if (widget.roomId != null) {
      await _shareToRoom(result);
    } else {
      // Add to local history
      final roll = MultiplayerRoll(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: '',
        userId: userProvider.firebaseUser?.uid ?? '',
        userName: userProvider.profile?.displayName ?? 'You',
        notation: _notation,
        total: result['total'] as int,
        individualRolls: List<int>.from(result['rolls'] as List),
        modifier: _modifier,
        withAdvantage: _advantage ? true : null,
        withDisadvantage: _disadvantage ? true : null,
        timestamp: DateTime.now(),
      );
      setState(() => _localHistory.insert(0, roll));
    }
  }

  Future<void> _shareToRoom(Map<String, dynamic> result) async {
    if (widget.roomId == null) return;
    final userProvider = context.read<UserProvider>();
    final uid = userProvider.firebaseUser?.uid;
    if (uid == null) return;

    final roll = MultiplayerRoll(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: widget.roomId!,
      userId: uid,
      userName: userProvider.profile?.displayName ?? 'Player',
      notation: _notation,
      total: result['total'] as int,
      individualRolls: List<int>.from(result['rolls'] as List),
      modifier: _modifier,
      withAdvantage: _advantage ? true : null,
      withDisadvantage: _disadvantage ? true : null,
      timestamp: DateTime.now(),
    );

    try {
      await _rollService.shareRoll(roll);
      // Also update local history from room provider
      context.read<RoomProvider>().addRoll(roll);
    } catch (_) {}
  }

  Color _diceColor(int sides) {
    switch (sides) {
      case 4: return AppColors.diceD4;
      case 6: return AppColors.diceD6;
      case 8: return AppColors.diceD8;
      case 10: return AppColors.diceD10;
      case 12: return AppColors.diceD12;
      case 20: return AppColors.diceD20;
      case 100: return AppColors.diceD100;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiplayer = widget.roomId != null;
    final roomProvider = isMultiplayer ? context.watch<RoomProvider>() : null;
    final displayHistory = isMultiplayer
        ? (roomProvider?.rollHistory ?? _localHistory)
        : _localHistory;
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isMultiplayer ? 'Roll Dice' : 'Solo Roll'),
        actions: [
          if (isMultiplayer && roomProvider != null &&
              roomProvider.participants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '${roomProvider.participants.length} online',
                  style: AppStyles.bodySmall,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dice type selector
                    _buildDiceSelector(),
                    const SizedBox(height: 20),
                    // Count and modifier
                    _buildCountModifier(),
                    const SizedBox(height: 20),
                    // Notation preview
                    Center(
                      child: Text(
                        _notation,
                        style: AppStyles.heading2.copyWith(
                          color: _diceColor(_selectedSides),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Advantage / Disadvantage
                    _buildModeSelector(),
                    const SizedBox(height: 24),
                    // Roll button
                    _buildRollButton(),
                    const SizedBox(height: 24),
                    // Result display
                    if (_lastResult != null) _buildResultDisplay(),
                    // Room participants
                    if (isMultiplayer && roomProvider != null &&
                        roomProvider.participants.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('In This Room', style: AppStyles.heading3),
                      const SizedBox(height: 8),
                      RoomParticipantsWidget(
                        participants: roomProvider.participants,
                        ownerId: roomProvider.currentRoom?.ownerId ?? '',
                        compact: true,
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Roll history
                    if (displayHistory.isNotEmpty) ...[
                      Text('Roll History', style: AppStyles.heading3),
                      const SizedBox(height: 8),
                      RollHistoryWidget(
                        rolls: displayHistory,
                        filterUserId: userProvider.firebaseUser?.uid,
                        onClear: isMultiplayer
                            ? null
                            : () => setState(() => _localHistory.clear()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dice Type', style: AppStyles.heading3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _diceOptions.map((sides) {
            final selected = _selectedSides == sides;
            final color = _diceColor(sides);
            return GestureDetector(
              onTap: () => setState(() => _selectedSides = sides),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.3) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : AppColors.divider,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.casino_rounded, size: 20,
                        color: AppColors.textPrimary),
                    Text(
                      'd$sides',
                      style: TextStyle(
                        color: selected ? color : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCountModifier() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dice Count', style: AppStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: '1',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Modifier', style: AppStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _modifierController,
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                decoration: const InputDecoration(
                  hintText: '0',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: 'Normal',
            selected: !_advantage && !_disadvantage,
            color: AppColors.primary,
            onTap: () => _setMode(false, false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModeButton(
            label: 'Advantage',
            selected: _advantage,
            color: AppColors.success,
            onTap: () => _setMode(true, false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModeButton(
            label: 'Disadvantage',
            selected: _disadvantage,
            color: AppColors.error,
            onTap: () => _setMode(false, true),
          ),
        ),
      ],
    );
  }

  Widget _buildRollButton() {
    return GestureDetector(
      onTap: _rolling ? null : _roll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 72,
        decoration: BoxDecoration(
          color: _rolling
              ? AppColors.primary.withOpacity(0.5)
              : _diceColor(_selectedSides),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _rolling
              ? []
              : [
                  BoxShadow(
                    color: _diceColor(_selectedSides).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _rolling
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.casino_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'ROLL $_notation',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    final result = _lastResult!;
    final total = result['total'] as int;
    final rolls = List<int>.from(result['rolls'] as List);
    final mod = result['modifier'] as int? ?? 0;
    final isAdvantage = result['advantage'] as bool? ?? false;
    final isDisadvantage = result['disadvantage'] as bool? ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Result', style: AppStyles.label),
            const SizedBox(height: 8),
            ScaleTransition(
              scale: _scaleAnim,
              child: Text(
                total.toString(),
                style: AppStyles.rollResult.copyWith(
                  color: _diceColor(_selectedSides),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isAdvantage)
              const Text('with Advantage',
                  style: TextStyle(color: AppColors.success)),
            if (isDisadvantage)
              const Text('with Disadvantage',
                  style: TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: rolls.map((r) => _DieResult(value: r)).toList(),
            ),
            if (mod != 0) ...[
              const SizedBox(height: 8),
              Text(
                'Modifier: ${mod > 0 ? '+' : ''}$mod',
                style: AppStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    Key? key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DieResult extends StatelessWidget {
  final int value;

  const _DieResult({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
