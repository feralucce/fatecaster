import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/dice_service.dart';
import '../utils/validators.dart';
import '../utils/debouncer.dart';
import '../widgets/error_dialog.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/help_tooltip.dart';
import '../widgets/skeleton_loader.dart';

/// The main dice-rolling screen.
///
/// Features:
/// - Dice notation input with real-time validation
/// - Normal / Advantage / Disadvantage roll modes
/// - Debounced validation feedback while typing
/// - Roll history with empty state
/// - Friendly error handling for invalid notation
class DiceRollingScreen extends StatefulWidget {
  const DiceRollingScreen({super.key});

  @override
  State<DiceRollingScreen> createState() => _DiceRollingScreenState();
}

class _DiceRollingScreenState extends State<DiceRollingScreen>
    with SingleTickerProviderStateMixin {
  final _diceController = TextEditingController();
  final _focusNode = FocusNode();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 350));
  final _diceService = DiceService();

  final List<_RollEntry> _rollHistory = [];

  String? _validationError;
  bool _isRolling = false;
  _RollMode _mode = _RollMode.normal;

  // Animation controller for result reveal
  late final AnimationController _resultAnimController;
  late final Animation<double> _resultFade;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _resultFade = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOut,
    );
    _diceController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _diceController.removeListener(_onInputChanged);
    _diceController.dispose();
    _focusNode.dispose();
    _debouncer.cancel();
    _resultAnimController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Input handling
  // ---------------------------------------------------------------------------

  void _onInputChanged() {
    // Immediately clear old error to avoid stale red while user types.
    if (_validationError != null) {
      setState(() => _validationError = null);
    }
    _debouncer.run(() {
      final error = Validators.diceNotation(_diceController.text);
      if (mounted) setState(() => _validationError = error);
    });
  }

  // ---------------------------------------------------------------------------
  // Rolling
  // ---------------------------------------------------------------------------

  Future<void> _roll() async {
    _focusNode.unfocus();

    final notation = _diceController.text.trim();
    final error = Validators.diceNotation(notation);
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }

    setState(() => _isRolling = true);

    try {
      // Small artificial delay for UX effect on fast devices.
      await Future<void>.delayed(const Duration(milliseconds: 150));

      Map<String, dynamic> result;
      switch (_mode) {
        case _RollMode.normal:
          result = _diceService.rollDice(notation);
        case _RollMode.advantage:
          result = _diceService.rollWithAdvantage(notation);
        case _RollMode.disadvantage:
          result = _diceService.rollWithDisadvantage(notation);
      }

      if (!mounted) return;

      final entry = _RollEntry(
        notation: notation,
        result: result,
        mode: _mode,
        timestamp: DateTime.now(),
      );

      setState(() {
        _rollHistory.insert(0, entry);
        _validationError = null;
      });

      // Animate result reveal.
      _resultAnimController
        ..reset()
        ..forward();

      SnackbarHelper.showSuccess(
        context,
        '${_mode.label}: ${notation} → ${result['total']}',
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() => _validationError = e.message);
    } catch (e) {
      if (!mounted) return;
      ErrorDialog.show(
        context,
        title: 'Roll Failed',
        message: 'An unexpected error occurred while rolling. Please try again.',
        onRetry: _roll,
      );
    } finally {
      if (mounted) setState(() => _isRolling = false);
    }
  }

  void _clearHistory() {
    setState(() => _rollHistory.clear());
    SnackbarHelper.showInfo(context, 'Roll history cleared.');
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isValid = _validationError == null &&
        _diceController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        actions: [
          if (_rollHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear history',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Input card ──────────────────────────────────────────────────
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Notation field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _diceController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            labelText: 'Dice notation',
                            hintText: 'e.g. 2d6, 1d20+5, 3d8-2',
                            prefixIcon:
                                const Icon(Icons.casino_outlined),
                            errorText: _validationError,
                            suffixIcon: _diceController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _diceController.clear();
                                      setState(
                                          () => _validationError = null);
                                    },
                                    tooltip: 'Clear',
                                  )
                                : null,
                          ),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          onSubmitted: (_) => _roll(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d dD+\-]'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: DiceNotationHelpTooltip(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Roll mode toggle
                  Row(
                    children: [
                      Text(
                        'Mode',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(width: 4),
                      const AdvantageHelpTooltip(),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_RollMode>(
                    segments: const [
                      ButtonSegment(
                        value: _RollMode.normal,
                        label: Text('Normal'),
                        icon: Icon(Icons.remove_rounded),
                      ),
                      ButtonSegment(
                        value: _RollMode.advantage,
                        label: Text('Adv'),
                        icon: Icon(Icons.arrow_upward_rounded),
                      ),
                      ButtonSegment(
                        value: _RollMode.disadvantage,
                        label: Text('Dis'),
                        icon: Icon(Icons.arrow_downward_rounded),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) =>
                        setState(() => _mode = s.first),
                  ),
                  const SizedBox(height: 20),

                  // Roll button
                  FilledButton.icon(
                    onPressed: (_isRolling || !isValid) ? null : _roll,
                    icon: _isRolling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.casino_rounded),
                    label: Text(_isRolling ? 'Rolling…' : 'Roll'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Latest result ────────────────────────────────────────────────
          if (_rollHistory.isNotEmpty)
            FadeTransition(
              opacity: _resultFade,
              child: _LatestResultCard(entry: _rollHistory.first),
            ),

          // ── History list ─────────────────────────────────────────────────
          Expanded(
            child: _rollHistory.isEmpty
                ? EmptyStateWidget.rollHistory(
                    onRollDice: () => _focusNode.requestFocus(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _rollHistory.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, i) =>
                        _RollHistoryTile(entry: _rollHistory[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _LatestResultCard extends StatelessWidget {
  final _RollEntry entry;
  const _LatestResultCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rolls = entry.result['rolls'] as List<int>;
    final total = entry.result['total'] as int;
    final modifier = entry.result['modifier'] as int;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.casino_rounded,
                    color: colorScheme.onPrimaryContainer, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${entry.notation}  ·  ${entry.mode.label}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Text(
                  entry.timestamp.toLocal().toString().substring(11, 19),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '$total',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final r in rolls)
                        _DieChip(value: r, color: colorScheme.primary),
                      if (modifier != 0)
                        _DieChip(
                          value: modifier,
                          color: colorScheme.secondary,
                          prefix: modifier > 0 ? '+' : '',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DieChip extends StatelessWidget {
  final int value;
  final Color color;
  final String prefix;

  const _DieChip({
    required this.value,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$prefix$value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _RollHistoryTile extends StatelessWidget {
  final _RollEntry entry;
  const _RollHistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = entry.result['total'] as int;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: colorScheme.surfaceVariant.withOpacity(0.4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '$total',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        entry.notation,
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        entry.mode.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        entry.timestamp.toLocal().toString().substring(11, 19),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum _RollMode {
  normal,
  advantage,
  disadvantage;

  String get label {
    switch (this) {
      case _RollMode.normal:
        return 'Normal';
      case _RollMode.advantage:
        return 'Advantage';
      case _RollMode.disadvantage:
        return 'Disadvantage';
    }
  }
}

class _RollEntry {
  final String notation;
  final Map<String, dynamic> result;
  final _RollMode mode;
  final DateTime timestamp;

  const _RollEntry({
    required this.notation,
    required this.result,
    required this.mode,
    required this.timestamp,
  });
}
