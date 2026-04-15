import 'package:firebase_database/firebase_database.dart';
import '../models/room_model.dart';
import '../models/room_participant.dart';

class MultiplayerRoomService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference get _rooms => _db.ref('rooms');

  /// Creates a new room and returns the room ID.
  Future<String> createRoom({
    required String name,
    required String ownerId,
    required String ownerName,
    required int maxPlayers,
    String? description,
  }) async {
    final ref = _rooms.push();
    final roomId = ref.key!;
    final room = RoomModel(
      id: roomId,
      name: name,
      ownerId: ownerId,
      ownerName: ownerName,
      maxPlayers: maxPlayers,
      description: description,
      createdAt: DateTime.now(),
    );
    await ref.set(room.toMap());
    // Add owner as first participant
    await _db.ref('rooms/$roomId/participants/$ownerId').set(
          RoomParticipant(
            userId: ownerId,
            displayName: ownerName,
            joinedAt: DateTime.now(),
          ).toMap(),
        );
    return roomId;
  }

  /// Joins an existing room.
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) async {
    final roomSnap = await _rooms.child(roomId).get();
    if (!roomSnap.exists) {
      throw Exception('Room not found.');
    }
    final roomData =
        Map<String, dynamic>.from(roomSnap.value as Map);
    final maxPlayers = (roomData['maxPlayers'] as num?)?.toInt() ?? 10;

    final participantsSnap =
        await _db.ref('rooms/$roomId/participants').get();
    final currentCount =
        participantsSnap.exists ? (participantsSnap.value as Map).length : 0;

    if (currentCount >= maxPlayers) {
      throw Exception('Room is full.');
    }

    await _db.ref('rooms/$roomId/participants/$userId').set(
          RoomParticipant(
            userId: userId,
            displayName: displayName,
            avatarUrl: avatarUrl,
            joinedAt: DateTime.now(),
          ).toMap(),
        );
  }

  /// Leaves a room. If the user is the owner, deletes the room.
  Future<void> leaveRoom({
    required String roomId,
    required String userId,
    required String ownerId,
  }) async {
    if (userId == ownerId) {
      await _rooms.child(roomId).remove();
    } else {
      await _db.ref('rooms/$roomId/participants/$userId').remove();
    }
  }

  /// Gets a room by ID (one-time fetch).
  Future<RoomModel?> getRoom(String roomId) async {
    final snap = await _rooms.child(roomId).get();
    if (!snap.exists) return null;
    final data = Map<String, dynamic>.from(snap.value as Map);
    return RoomModel.fromMap(roomId, data);
  }

  /// Stream of participants in a room.
  Stream<List<RoomParticipant>> participantsStream(String roomId) {
    return _db
        .ref('rooms/$roomId/participants')
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries
          .map((e) => RoomParticipant.fromMap(
                e.key,
                Map<String, dynamic>.from(e.value as Map),
              ))
          .toList();
    });
  }

  /// Returns a list of all active rooms (for browsing).
  Future<List<RoomModel>> listActiveRooms() async {
    final snap = await _rooms
        .orderByChild('isActive')
        .equalTo(true)
        .get();
    if (!snap.exists || snap.value == null) return [];
    final data = Map<String, dynamic>.from(snap.value as Map);
    return data.entries
        .map((e) => RoomModel.fromMap(
              e.key,
              Map<String, dynamic>.from(e.value as Map),
            ))
        .toList();
  }

  /// Stream of a single room's metadata.
  Stream<RoomModel?> roomStream(String roomId) {
    return _rooms.child(roomId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      return RoomModel.fromMap(
        roomId,
        Map<String, dynamic>.from(event.snapshot.value as Map),
      );
    });
  }
}
