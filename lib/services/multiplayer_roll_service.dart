import 'package:firebase_database/firebase_database.dart';
import '../models/multiplayer_roll.dart';

class MultiplayerRollService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference _rollsRef(String roomId) =>
      _db.ref('rooms/$roomId/rolls');

  /// Shares a roll to the room.
  Future<void> shareRoll(MultiplayerRoll roll) async {
    final ref = _rollsRef(roll.roomId).push();
    await ref.set(roll.toMap());
    // Update participant's last roll result
    await _db
        .ref('rooms/${roll.roomId}/participants/${roll.userId}/lastRollResult')
        .set(roll.total);
  }

  /// Stream of new rolls added to the room (real-time feed).
  Stream<MultiplayerRoll> rollStream(String roomId) {
    return _rollsRef(roomId).onChildAdded.map((event) {
      final data =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      return MultiplayerRoll.fromMap(event.snapshot.key!, data);
    });
  }

  /// Fetch recent roll history for a room.
  Future<List<MultiplayerRoll>> getRollHistory(String roomId,
      {int limit = 50}) async {
    final snap = await _rollsRef(roomId)
        .orderByChild('timestamp')
        .limitToLast(limit)
        .get();
    if (!snap.exists || snap.value == null) return [];
    final data = Map<String, dynamic>.from(snap.value as Map);
    final rolls = data.entries
        .map((e) => MultiplayerRoll.fromMap(
              e.key,
              Map<String, dynamic>.from(e.value as Map),
            ))
        .toList();
    rolls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return rolls;
  }
}
