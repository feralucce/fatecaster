class RoomModel {
  final String roomId;
  final String ownerId;
  final DateTime createdAt;
  final int maxPlayers;

  RoomModel({
    required this.roomId,
    required this.ownerId,
    required this.createdAt,
    required this.maxPlayers,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'maxPlayers': maxPlayers,
    };
  }

  factory RoomModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return RoomModel(
      roomId: id,
      ownerId: map['ownerId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      maxPlayers: map['maxPlayers'] as int,
    );
  }
}
