class RoomModel {
  final String id;
  final String name;
  final String ownerId;
  final String ownerName;
  final int maxPlayers;
  final String? description;
  final DateTime createdAt;
  final bool isActive;

  const RoomModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    required this.maxPlayers,
    this.description,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'maxPlayers': maxPlayers,
        'description': description,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'isActive': isActive,
      };

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) => RoomModel(
        id: id,
        name: map['name'] as String,
        ownerId: map['ownerId'] as String,
        ownerName: map['ownerName'] as String? ?? 'Unknown',
        maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 10,
        description: map['description'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (map['createdAt'] as num).toInt())
            : DateTime.now(),
        isActive: map['isActive'] as bool? ?? true,
      );
}
