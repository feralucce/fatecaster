import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/room_model.dart';
import '../models/room_participant.dart';
import '../models/multiplayer_roll.dart';

class MultiplayerRoomService {
  final FirebaseDatabase _database;
  final FirebaseAuth _auth;

  MultiplayerRoomService({
    FirebaseDatabase? database,
    FirebaseAuth? auth,
  })  : _database = database ?? FirebaseDatabase.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DatabaseReference get _roomsRef => _database.ref('rooms');

  /// Creates a new multiplayer room owned by the current user.
  Future<RoomModel> createRoom({int maxPlayers = 8}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User must be signed in to create a room');

    final newRoomRef = _roomsRef.push();
    final room = RoomModel(
      roomId: newRoomRef.key!,
      ownerId: user.uid,
      createdAt: DateTime.now().toUtc(),
      maxPlayers: maxPlayers,
    );

    await newRoomRef.set(room.toMap());

    // Add the owner as a participant.
    await _addParticipant(room.roomId, user);

    return room;
  }

  /// Joins an existing room by its [roomId].
  Future<void> joinRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User must be signed in to join a room');

    final snapshot = await _roomsRef.child(roomId).get();
    if (!snapshot.exists) throw ArgumentError('Room $roomId does not exist');

    final roomData = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final maxPlayers = roomData['maxPlayers'] as int;

    final participantsSnapshot =
        await _roomsRef.child('$roomId/participants').get();
    final currentCount =
        participantsSnapshot.exists ? (participantsSnapshot.value as Map).length : 0;

    if (currentCount >= maxPlayers) {
      throw StateError('Room $roomId is full ($maxPlayers/$maxPlayers players)');
    }

    await _addParticipant(roomId, user);
  }

  /// Leaves a room. If the current user is the owner the room is deleted.
  Future<void> leaveRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User must be signed in to leave a room');

    final snapshot = await _roomsRef.child(roomId).get();
    if (!snapshot.exists) return;

    final roomData = Map<dynamic, dynamic>.from(snapshot.value as Map);
    if (roomData['ownerId'] == user.uid) {
      // Owner leaving removes the entire room.
      await _roomsRef.child(roomId).remove();
    } else {
      await _roomsRef.child('$roomId/participants/${user.uid}').remove();
    }
  }

  /// Returns all rooms the current user participates in.
  Future<List<RoomModel>> listActiveRooms() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User must be signed in to list rooms');

    final snapshot = await _roomsRef.get();
    if (!snapshot.exists) return [];

    final rooms = <RoomModel>[];
    final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

    for (final entry in data.entries) {
      final roomId = entry.key as String;
      final roomData = Map<dynamic, dynamic>.from(entry.value as Map);

      // Include rooms where the user is a participant.
      if (roomData['participants'] != null &&
          (roomData['participants'] as Map).containsKey(user.uid)) {
        rooms.add(RoomModel.fromMap(roomId, roomData));
      }
    }

    return rooms;
  }

  /// Returns the list of participants for a given [roomId].
  Future<List<RoomParticipant>> getRoomParticipants(String roomId) async {
    final snapshot = await _roomsRef.child('$roomId/participants').get();
    if (!snapshot.exists) return [];

    final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
    return data.entries
        .map((e) => RoomParticipant.fromMap(
            e.key as String, Map<dynamic, dynamic>.from(e.value as Map)))
        .toList();
  }

  /// Broadcasts a roll result to all participants of [roomId] by writing
  /// directly to the Realtime Database under `rooms/{roomId}/rolls`.
  Future<MultiplayerRoll> broadcastRoll(
      String roomId, Map<String, dynamic> rollResult) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to broadcast a roll');
    }

    final rollRef = _roomsRef.child('$roomId/rolls').push();
    final roll = MultiplayerRoll(
      rollId: rollRef.key!,
      userId: user.uid,
      timestamp: DateTime.now().toUtc(),
      rollResult: rollResult,
      roomId: roomId,
    );

    await rollRef.set(roll.toMap());
    return roll;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _addParticipant(String roomId, User user) async {
    final participant = RoomParticipant(
      userId: user.uid,
      username: user.displayName ?? user.email ?? user.uid,
      joinedAt: DateTime.now().toUtc(),
    );

    await _roomsRef
        .child('$roomId/participants/${user.uid}')
        .set(participant.toMap());
  }
}
