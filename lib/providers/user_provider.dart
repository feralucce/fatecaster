import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserProfile? _profile;
  bool _loading = false;

  User? get firebaseUser => _firebaseUser;
  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get isLoggedIn => _firebaseUser != null;

  /// Called when auth state changes.
  Future<void> setUser(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadProfile(user.uid);
    } else {
      _profile = null;
    }
    notifyListeners();
  }

  Future<void> _loadProfile(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      _profile = await _userService.getProfile(uid);
      // Create profile if it doesn't exist yet
      if (_profile == null && _firebaseUser != null) {
        _profile = UserProfile(
          uid: _firebaseUser!.uid,
          displayName: _firebaseUser!.displayName ?? 'User',
          email: _firebaseUser!.email ?? '',
        );
        await _userService.saveProfile(_profile!);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Refresh user profile from Firestore.
  Future<void> refreshProfile() async {
    if (_firebaseUser != null) {
      await _loadProfile(_firebaseUser!.uid);
    }
  }

  /// Update display name.
  Future<void> updateDisplayName(String displayName) async {
    if (_firebaseUser == null || _profile == null) return;
    await _userService.updateProfile(_firebaseUser!.uid,
        displayName: displayName);
    _profile = _profile!.copyWith(displayName: displayName);
    notifyListeners();
  }

  /// Update avatar URL.
  Future<void> updateAvatarUrl(String avatarUrl) async {
    if (_firebaseUser == null || _profile == null) return;
    await _userService.updateProfile(_firebaseUser!.uid, avatarUrl: avatarUrl);
    _profile = _profile!.copyWith(avatarUrl: avatarUrl);
    notifyListeners();
  }

  /// Record a roll and update stats.
  Future<void> recordRoll(int result) async {
    if (_firebaseUser == null || _profile == null) return;
    await _userService.recordRoll(_firebaseUser!.uid, result);
    await refreshProfile();
  }
}
