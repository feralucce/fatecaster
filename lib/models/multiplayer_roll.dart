class MultiplayerRoll {
  final String id;
  final String roomId;
  final String userId;
  final String userName;
  final String notation;
  final int total;
  final List<int> individualRolls;
  final int modifier;
  final bool? withAdvantage;
  final bool? withDisadvantage;
  final DateTime timestamp;

  const MultiplayerRoll({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.notation,
    required this.total,
    required this.individualRolls,
    this.modifier = 0,
    this.withAdvantage,
    this.withDisadvantage,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'roomId': roomId,
        'userId': userId,
        'userName': userName,
        'notation': notation,
        'total': total,
        'individualRolls': individualRolls,
        'modifier': modifier,
        'withAdvantage': withAdvantage,
        'withDisadvantage': withDisadvantage,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory MultiplayerRoll.fromMap(String id, Map<String, dynamic> map) =>
      MultiplayerRoll(
        id: id,
        roomId: map['roomId'] as String? ?? '',
        userId: map['userId'] as String,
        userName: map['userName'] as String? ?? 'Unknown',
        notation: map['notation'] as String,
        total: (map['total'] as num).toInt(),
        individualRolls: (map['individualRolls'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [],
        modifier: (map['modifier'] as num?)?.toInt() ?? 0,
        withAdvantage: map['withAdvantage'] as bool?,
        withDisadvantage: map['withDisadvantage'] as bool?,
        timestamp: map['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (map['timestamp'] as num).toInt())
            : DateTime.now(),
      );
}
