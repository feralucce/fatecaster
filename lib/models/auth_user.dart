class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  factory AuthUser.fromMap(Map<String, dynamic> data, String uid) {
    return AuthUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
