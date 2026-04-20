class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
        uid: map['uid'] as String,
        email: map['email'] as String,
        displayName: map['displayName'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) =>
      AuthUser(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt ?? this.createdAt,
      );
}
