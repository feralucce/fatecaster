import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Get user profile by UID.
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  /// Create or update a user profile.
  Future<void> saveProfile(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  /// Update display name and/or avatar.
  Future<void> updateProfile(
    String uid, {
    String? displayName,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (updates.isNotEmpty) {
      await _users.doc(uid).update(updates);
    }
  }

  /// Update user preferences.
  Future<void> updatePreferences(
      String uid, UserPreferences preferences) async {
    await _users
        .doc(uid)
        .update({'preferences': preferences.toMap()});
  }

  /// Record a new roll result and update running stats.
  Future<void> recordRoll(String uid, int rollResult) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data();

    final currentStats = data != null && data['stats'] != null
        ? UserStats.fromMap(Map<String, dynamic>.from(data['stats'] as Map))
        : const UserStats();

    final newTotal = currentStats.totalRolls + 1;
    final newAverage =
        ((currentStats.averageResult * currentStats.totalRolls) + rollResult) /
            newTotal;
    final newHigh = currentStats.highestRoll == 0
        ? rollResult
        : (rollResult > currentStats.highestRoll
            ? rollResult
            : currentStats.highestRoll);
    final newLow = currentStats.lowestRoll == 0
        ? rollResult
        : (rollResult < currentStats.lowestRoll
            ? rollResult
            : currentStats.lowestRoll);

    final updatedStats = UserStats(
      totalRolls: newTotal,
      averageResult: newAverage,
      highestRoll: newHigh,
      lowestRoll: newLow,
    );

    await _users
        .doc(uid)
        .set({'stats': updatedStats.toMap()}, SetOptions(merge: true));
  }
}
