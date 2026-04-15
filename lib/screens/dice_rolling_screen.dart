import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/dice_service.dart';

class DiceRollingScreen extends StatefulWidget {
  @override
  _DiceRollingScreenState createState() => _DiceRollingScreenState();
}

class _DiceRollingScreenState extends State<DiceRollingScreen> {
  final TextEditingController _diceController = TextEditingController();
  final List<String> _rollHistory = [];
  final DiceService _diceService = DiceService();
  String _result = '';

  void _rollNormal() {
    final notation = _diceController.text.trim();
    if (notation.isEmpty) return;
    try {
      final timestamp = DateTime.now().toUtc();
      final result = _diceService.rollDice(notation);
      final total = result['total'] as int;
      setState(() {
        _result = '$total';
        _rollHistory.add('[$timestamp] $notation = $total');
      });
    } catch (e) {
      setState(() { _result = 'Invalid notation'; });
    }
  }

  void _rollAdvantage() {
    final notation = _diceController.text.trim();
    if (notation.isEmpty) return;
    try {
      final timestamp = DateTime.now().toUtc();
      final result = _diceService.rollWithAdvantage(notation);
      final total = result['total'] as int;
      setState(() {
        _result = '$total (advantage)';
        _rollHistory.add('[$timestamp] $notation (adv) = $total');
      });
    } catch (e) {
      setState(() { _result = 'Invalid notation'; });
    }
  }

  void _rollDisadvantage() {
    final notation = _diceController.text.trim();
    if (notation.isEmpty) return;
    try {
      final timestamp = DateTime.now().toUtc();
      final result = _diceService.rollWithDisadvantage(notation);
      final total = result['total'] as int;
      setState(() {
        _result = '$total (disadvantage)';
        _rollHistory.add('[$timestamp] $notation (dis) = $total');
      });
    } catch (e) {
      setState(() { _result = 'Invalid notation'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dice Roller')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _diceController,
                  decoration: const InputDecoration(labelText: 'Enter dice notation (e.g., 2d6)'),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*d\d*([+-]\d*)?'))],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(onPressed: _rollNormal, child: const Text('Roll Normal')),
                    ElevatedButton(onPressed: _rollAdvantage, child: const Text('Roll Advantage')),
                    ElevatedButton(onPressed: _rollDisadvantage, child: const Text('Roll Disadvantage')),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Result: $_result'),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _rollHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text(_rollHistory[index]));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
