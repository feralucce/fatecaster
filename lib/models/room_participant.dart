class RoomParticipant {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final DateTime joinedAt;
  final bool isOnline;
  final int? lastRollResult;

  const RoomParticipant({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.joinedAt,
    this.isOnline = true,
    this.lastRollResult,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'joinedAt': joinedAt.millisecondsSinceEpoch,
        'isOnline': isOnline,
        'lastRollResult': lastRollResult,
      };

  factory RoomParticipant.fromMap(String userId, Map<String, dynamic> map) =>
      RoomParticipant(
        userId: userId,
        displayName: map['displayName'] as String? ?? 'Unknown',
        avatarUrl: map['avatarUrl'] as String?,
        joinedAt: map['joinedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (map['joinedAt'] as num).toInt())
            : DateTime.now(),
        isOnline: map['isOnline'] as bool? ?? true,
        lastRollResult: (map['lastRollResult'] as num?)?.toInt(),
      );

  RoomParticipant copyWith({
    bool? isOnline,
    int? lastRollResult,
  }) =>
      RoomParticipant(
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        joinedAt: joinedAt,
        isOnline: isOnline ?? this.isOnline,
        lastRollResult: lastRollResult ?? this.lastRollResult,
      );
}
