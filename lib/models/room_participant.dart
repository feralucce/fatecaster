class RoomParticipant {
  final String userId;
  final String username;
  final DateTime joinedAt;

  RoomParticipant({
    required this.userId,
    required this.username,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory RoomParticipant.fromMap(String id, Map<dynamic, dynamic> map) {
    return RoomParticipant(
      userId: id,
      username: map['username'] as String,
      joinedAt: DateTime.parse(map['joinedAt'] as String),
    );
  }
}
