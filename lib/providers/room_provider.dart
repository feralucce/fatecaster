import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../models/room_participant.dart';
import '../models/multiplayer_roll.dart';
import '../services/multiplayer_room_service.dart';
import '../services/multiplayer_roll_service.dart';

class RoomProvider with ChangeNotifier {
  final MultiplayerRoomService _roomService = MultiplayerRoomService();
  final MultiplayerRollService _rollService = MultiplayerRollService();

  RoomModel? _currentRoom;
  List<RoomParticipant> _participants = [];
  List<MultiplayerRoll> _rollHistory = [];
  StreamSubscription<List<RoomParticipant>>? _participantsSub;
  StreamSubscription<MultiplayerRoll>? _rollSub;

  RoomModel? get currentRoom => _currentRoom;
  List<RoomParticipant> get participants => List.unmodifiable(_participants);
  List<MultiplayerRoll> get rollHistory => List.unmodifiable(_rollHistory);
  bool get inRoom => _currentRoom != null;

  /// Load room data and subscribe to real-time updates.
  Future<void> joinRoom(String roomId) async {
    _cancelSubscriptions();
    final room = await _roomService.getRoom(roomId);
    _currentRoom = room;
    _rollHistory = await _rollService.getRollHistory(roomId);
    notifyListeners();

    _participantsSub = _roomService
        .participantsStream(roomId)
        .listen((participants) {
      _participants = participants;
      notifyListeners();
    });

    _rollSub = _rollService.rollStream(roomId).listen((roll) {
      // Avoid duplicates already fetched in history
      if (!_rollHistory.any((r) => r.id == roll.id)) {
        _rollHistory.insert(0, roll);
        notifyListeners();
      }
    });
  }

  /// Add a new roll result locally (from rollStream).
  void addRoll(MultiplayerRoll roll) {
    if (!_rollHistory.any((r) => r.id == roll.id)) {
      _rollHistory.insert(0, roll);
      notifyListeners();
    }
  }

  /// Leave the current room and clean up subscriptions.
  void leaveRoom() {
    _cancelSubscriptions();
    _currentRoom = null;
    _participants = [];
    _rollHistory = [];
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _participantsSub?.cancel();
    _participantsSub = null;
    _rollSub?.cancel();
    _rollSub = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
