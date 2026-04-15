import 'dart:math';

class DiceService {
  /// Supported dice types.
  static const List<int> diceTypes = [4, 6, 8, 10, 12, 20, 100];

  /// Parses a dice notation string (e.g., '1d6+2') into its components.
  Map<String, dynamic> parseDiceNotation(String notation) {
    final regex = RegExp(r'^(\d+)d(\d+)([+-]\d+)?$', caseSensitive: false);
    final match = regex.firstMatch(notation.trim());
    if (match == null) {
      throw FormatException('Invalid dice notation: $notation');
    }

    final numberOfDice = int.parse(match.group(1) ?? '1');
    final numberOfSides = int.parse(match.group(2)!);
    final modifier = match.group(3) != null ? int.parse(match.group(3)!) : 0;
    return {
      'numberOfDice': numberOfDice,
      'numberOfSides': numberOfSides,
      'modifier': modifier,
    };
  }

  /// Static helper: rolls using standard notation and returns a result string.
  static String roll(String notation) {
    try {
      final service = DiceService();
      final result = service.rollDice(notation);
      return '${result['notation']}: ${result['total']} '
          '(rolls: ${(result['rolls'] as List).join(', ')})';
    } catch (_) {
      return 'Invalid notation: $notation';
    }
  }

  /// Rolls the specified number of dice and returns the results along with the total.
  Map<String, dynamic> rollDice(String notation) {
    final parsed = parseDiceNotation(notation);
    final numberOfDice = parsed['numberOfDice'] as int;
    final numberOfSides = parsed['numberOfSides'] as int;
    final modifier = parsed['modifier'] as int;

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
      'notation': notation,
    };
  }

  /// Rolls dice with advantage (keep highest of two rolls).
  Map<String, dynamic> rollWithAdvantage(String notation) {
    final parsed = parseDiceNotation(notation);
    final numberOfDice = parsed['numberOfDice'] as int;
    final numberOfSides = parsed['numberOfSides'] as int;
    final modifier = parsed['modifier'] as int;

    final random = Random();

    final firstRolls = List.generate(
        numberOfDice, (_) => random.nextInt(numberOfSides) + 1);
    final firstTotal = firstRolls.reduce((a, b) => a + b);

    final secondRolls = List.generate(
        numberOfDice, (_) => random.nextInt(numberOfSides) + 1);
    final secondTotal = secondRolls.reduce((a, b) => a + b);

    final bestTotal = max(firstTotal, secondTotal);
    final bestRolls = bestTotal == firstTotal ? firstRolls : secondRolls;

    return {
      'rolls': bestRolls,
      'modifier': modifier,
      'total': bestTotal + modifier,
      'notation': notation,
      'advantage': true,
      'firstRollTotal': firstTotal,
      'secondRollTotal': secondTotal,
    };
  }

  /// Rolls dice with disadvantage (keep lowest of two rolls).
  Map<String, dynamic> rollWithDisadvantage(String notation) {
    final parsed = parseDiceNotation(notation);
    final numberOfDice = parsed['numberOfDice'] as int;
    final numberOfSides = parsed['numberOfSides'] as int;
    final modifier = parsed['modifier'] as int;

    final random = Random();

    final firstRolls = List.generate(
        numberOfDice, (_) => random.nextInt(numberOfSides) + 1);
    final firstTotal = firstRolls.reduce((a, b) => a + b);

    final secondRolls = List.generate(
        numberOfDice, (_) => random.nextInt(numberOfSides) + 1);
    final secondTotal = secondRolls.reduce((a, b) => a + b);

    final worstTotal = min(firstTotal, secondTotal);
    final worstRolls = worstTotal == firstTotal ? firstRolls : secondRolls;

    return {
      'rolls': worstRolls,
      'modifier': modifier,
      'total': worstTotal + modifier,
      'notation': notation,
      'disadvantage': true,
      'firstRollTotal': firstTotal,
      'secondRollTotal': secondTotal,
    };
  }
}
