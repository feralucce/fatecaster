import 'dart:math';

class DiceService {
  /// Parses a dice notation string (e.g., '1d6+2') into its components.
  Map<String, dynamic> parseDiceNotation(String notation) {
    final regex = RegExp(r'^(\d*)d(\d+)([+-]\d+)?$', caseSensitive: false);
    final match = regex.firstMatch(notation.trim());
    if (match == null) {
      throw FormatException('Invalid dice notation: $notation');
    }

    final countStr = match.group(1) ?? '';
    final numberOfDice = countStr.isEmpty ? 1 : int.parse(countStr);
    final numberOfSides = int.parse(match.group(2)!);
    final modifier = match.group(3) != null ? int.parse(match.group(3)!) : 0;
    return {
      'numberOfDice': numberOfDice,
      'numberOfSides': numberOfSides,
      'modifier': modifier
    };
  }

  /// Rolls the specified number of dice and returns the results along with the total.
  Map<String, dynamic> rollDice(String notation) {
    final parsed = parseDiceNotation(notation);
    final numberOfDice = parsed['numberOfDice'];
    final numberOfSides = parsed['numberOfSides'];
    final modifier = parsed['modifier'];
    
    final random = Random();
    final rolls = <int>[];
    int total = modifier;

    for (var i = 0; i < numberOfDice; i++) {
      final roll = random.nextInt(numberOfSides) + 1;
      rolls.add(roll);
      total += roll;
    }

    return {
      'rolls': rolls,
      'modifier': modifier,
      'total': total,
      'notation': notation
    };
  }

  /// Rolls dice with advantage (keep highest of two rolls).
  Map<String, dynamic> rollWithAdvantage(String notation) {
    final parsed = parseDiceNotation(notation);
    final numberOfDice = parsed['numberOfDice'];
    final numberOfSides = parsed['numberOfSides'];
    final modifier = parsed['modifier'];
    
    final random = Random();
    
    // First roll
    final firstRolls = <int>[];
    for (var i = 0; i < numberOfDice; i++) {
      firstRolls.add(random.nextInt(numberOfSides) + 1);
    }
    final firstTotal = firstRolls.reduce((a, b) => a + b);
    
    // Second roll
    final secondRolls = <int>[];
    for (var i = 0; i < numberOfDice; i++) {
      secondRolls.add(random.nextInt(numberOfSides) + 1);
    }
    final secondTotal = secondRolls.reduce((a, b) => a + b);
    
    // Keep the highest
    final bestTotal = max(firstTotal, secondTotal);
    final bestRolls = bestTotal == firstTotal ? firstRolls : secondRolls;

    return {
      'rolls': bestRolls,
      'modifier': modifier,
      'total': bestTotal + modifier,
      'notation': notation,
      'advantage': true,
      'firstRollTotal': firstTotal,
      'secondRollTotal': secondTotal
    };
  }

  /// Rolls dice with disadvantage (keep lowest of two rolls).
  Map<String, dynamic> rollWithDisadvantage(String notation) {
    final parsed = parseDiceNotation(notation);
    final numberOfDice = parsed['numberOfDice'];
    final numberOfSides = parsed['numberOfSides'];
    final modifier = parsed['modifier'];
    
    final random = Random();
    
    // First roll
    final firstRolls = <int>[];
    for (var i = 0; i < numberOfDice; i++) {
      firstRolls.add(random.nextInt(numberOfSides) + 1);
    }
    final firstTotal = firstRolls.reduce((a, b) => a + b);
    
    // Second roll
    final secondRolls = <int>[];
    for (var i = 0; i < numberOfDice; i++) {
      secondRolls.add(random.nextInt(numberOfSides) + 1);
    }
    final secondTotal = secondRolls.reduce((a, b) => a + b);
    
    // Keep the lowest
    final worstTotal = min(firstTotal, secondTotal);
    final worstRolls = worstTotal == firstTotal ? firstRolls : secondRolls;

    return {
      'rolls': worstRolls,
      'modifier': modifier,
      'total': worstTotal + modifier,
      'notation': notation,
      'disadvantage': true,
      'firstRollTotal': firstTotal,
      'secondRollTotal': secondTotal
    };
  }
}