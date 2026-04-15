import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/multiplayer_roll.dart';

class MultiplayerRollService {
  final FirebaseDatabase _database;
  final FirebaseAuth _auth;

  // Active stream subscriptions keyed by roomId.
  final Map<String, StreamSubscription<DatabaseEvent>> _subscriptions = {};

  MultiplayerRollService({
    FirebaseDatabase? database,
    FirebaseAuth? auth,
  })  : _database = database ?? FirebaseDatabase.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DatabaseReference _rollsRef(String roomId) =>
      _database.ref('rooms/$roomId/rolls');

  /// Shares a roll result to the specified [roomId].
  Future<MultiplayerRoll> shareRoll(
      String roomId, Map<String, dynamic> rollResult) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User must be signed in to share a roll');

    final rollRef = _rollsRef(roomId).push();
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

  /// Returns a [Stream] that emits a [MultiplayerRoll] each time a new roll is
  /// added to [roomId]. The stream also emits rolls from other members.
  Stream<MultiplayerRoll> listenForRolls(String roomId) {
    return _rollsRef(roomId).onChildAdded.map((event) {
      final snapshot = event.snapshot;
      return MultiplayerRoll.fromMap(
        snapshot.key!,
        Map<dynamic, dynamic>.from(snapshot.value as Map),
      );
    });
  }

  /// Starts listening to new rolls in [roomId] and invokes [onRoll] for each.
  /// Call [stopListening] with the same [roomId] to cancel the subscription.
  void startListening(String roomId, void Function(MultiplayerRoll) onRoll) {
    stopListening(roomId);
    _subscriptions[roomId] =
        listenForRolls(roomId).listen(onRoll, onError: (_) {});
  }

  /// Cancels the active subscription for [roomId] if one exists.
  void stopListening(String roomId) {
    _subscriptions.remove(roomId)?.cancel();
  }

  /// Cancels all active subscriptions.
  void stopAllListening() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Retrieves the complete roll history for [roomId] ordered by timestamp.
  Future<List<MultiplayerRoll>> getRollHistory(String roomId) async {
    final snapshot = await _rollsRef(roomId)
        .orderByChild('timestamp')
        .get();

    if (!snapshot.exists) return [];

    final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final rolls = data.entries
        .map((e) => MultiplayerRoll.fromMap(
            e.key as String, Map<dynamic, dynamic>.from(e.value as Map)))
        .toList();

    rolls.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return rolls;
  }
}
