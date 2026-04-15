import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dice_service.dart'; // Assuming this is the service you integrated

class DiceRollingScreen extends StatefulWidget {
  @override
  _DiceRollingScreenState createState() => _DiceRollingScreenState();
}

class _DiceRollingScreenState extends State<DiceRollingScreen> {
  final TextEditingController _diceController = TextEditingController();
  final List<String> _rollHistory = [];
  String _result = '';

  void _rollDice(String notation) {
    // Call to DiceService to perform the roll
    final DateTime timestamp = DateTime.now().toUtc();
    final String rollResult = DiceService.roll(notation); // Example method call
    setState(() {
      _result = '[0;32m$timestamp: $rollResult[0m';
      _rollHistory.add('[$timestamp] Rolled: $rollResult');
    });
  }

  void _rollNormal() => _rollDice(_diceController.text);
  void _rollAdvantage() => _rollDice('${_diceController.text}d2'); // Example advantage logic
  void _rollDisadvantage() => _rollDice('${_diceController.text}d0'); // Example disadvantage logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dice Roller')), 
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
                  decoration: InputDecoration(labelText: 'Enter dice notation (e.g., 2d6)'),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*d\d*$'))],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(onPressed: _rollNormal, child: Text('Roll Normal')), 
                    ElevatedButton(onPressed: _rollAdvantage, child: Text('Roll Advantage')), 
                    ElevatedButton(onPressed: _rollDisadvantage, child: Text('Roll Disadvantage')), 
                  ],
                ),
                SizedBox(height: 20),
                Text('Result: $_result'),
                SizedBox(height: 20),
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