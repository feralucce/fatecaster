class UserStats {
  final int totalRolls;
  final double averageResult;
  final int highestRoll;
  final int lowestRoll;

  const UserStats({
    this.totalRolls = 0,
    this.averageResult = 0.0,
    this.highestRoll = 0,
    this.lowestRoll = 0,
  });

  Map<String, dynamic> toMap() => {
        'totalRolls': totalRolls,
        'averageResult': averageResult,
        'highestRoll': highestRoll,
        'lowestRoll': lowestRoll,
      };

  factory UserStats.fromMap(Map<String, dynamic> map) => UserStats(
        totalRolls: (map['totalRolls'] as num?)?.toInt() ?? 0,
        averageResult: (map['averageResult'] as num?)?.toDouble() ?? 0.0,
        highestRoll: (map['highestRoll'] as num?)?.toInt() ?? 0,
        lowestRoll: (map['lowestRoll'] as num?)?.toInt() ?? 0,
      );
}

class UserPreferences {
  final bool darkMode;
  final bool notificationsEnabled;
  final String defaultDiceType;

  const UserPreferences({
    this.darkMode = true,
    this.notificationsEnabled = true,
    this.defaultDiceType = 'd20',
  });

  Map<String, dynamic> toMap() => {
        'darkMode': darkMode,
        'notificationsEnabled': notificationsEnabled,
        'defaultDiceType': defaultDiceType,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
        darkMode: map['darkMode'] as bool? ?? true,
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
        defaultDiceType: map['defaultDiceType'] as String? ?? 'd20',
      );
}

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final UserStats stats;
  final UserPreferences preferences;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.stats = const UserStats(),
    this.preferences = const UserPreferences(),
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'avatarUrl': avatarUrl,
        'stats': stats.toMap(),
        'preferences': preferences.toMap(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String,
        email: map['email'] as String,
        avatarUrl: map['avatarUrl'] as String?,
        stats: map['stats'] != null
            ? UserStats.fromMap(Map<String, dynamic>.from(map['stats'] as Map))
            : const UserStats(),
        preferences: map['preferences'] != null
            ? UserPreferences.fromMap(
                Map<String, dynamic>.from(map['preferences'] as Map))
            : const UserPreferences(),
      );

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    UserStats? stats,
    UserPreferences? preferences,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        stats: stats ?? this.stats,
        preferences: preferences ?? this.preferences,
      );
}
