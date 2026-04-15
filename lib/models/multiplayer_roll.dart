class MultiplayerRoll {
  final String rollId;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> rollResult;
  final String roomId;

  MultiplayerRoll({
    required this.rollId,
    required this.userId,
    required this.timestamp,
    required this.rollResult,
    required this.roomId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'rollResult': rollResult,
      'roomId': roomId,
    };
  }

  factory MultiplayerRoll.fromMap(String id, Map<dynamic, dynamic> map) {
    return MultiplayerRoll(
      rollId: id,
      userId: map['userId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      rollResult: Map<String, dynamic>.from(map['rollResult'] as Map),
      roomId: map['roomId'] as String,
    );
  }
}
