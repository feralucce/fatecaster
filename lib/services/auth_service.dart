import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user.
  User? get currentUser => _auth.currentUser;

  /// Sign up with email and password.
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName.trim());
    await user.reload();

    final authUser = AuthUser(
      uid: user.uid,
      email: user.email!,
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(authUser.toMap(), SetOptions(merge: true));

    return authUser;
  }

  /// Sign in with email and password.
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    return AuthUser(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName ?? 'User',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns a friendly error message for Firebase Auth errors.
  static String errorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
