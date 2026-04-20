/// Validation helpers for user-facing input fields.
///
/// Each method returns `null` when the value is valid, or a human-readable
/// error string when it is not.
class Validators {
  Validators._();

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  /// Returns `null` when [email] is a well-formed email address.
  static String? email(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email address is required.';
    }
    final trimmed = email.trim();
    // RFC 5322-inspired pattern – covers the vast majority of real addresses.
    final regex = RegExp(
      r'^[a-zA-Z0-9.!#$%&'
      r"'*+/=?^_`{|}~-]+"
      r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
      r'\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g. user@example.com).';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Password
  // ---------------------------------------------------------------------------

  /// Minimum required password length.
  static const int minPasswordLength = 8;

  /// Returns `null` when [password] meets minimum strength requirements.
  static String? password(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
      return 'Password must contain at least one letter.';
    }
    return null;
  }

  /// Returns `null` when [confirmPassword] matches [password].
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Returns a [PasswordStrength] value for the given password.
  static PasswordStrength passwordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    return PasswordStrength.strong;
  }

  // ---------------------------------------------------------------------------
  // Room code
  // ---------------------------------------------------------------------------

  /// Room codes are exactly 6 alphanumeric characters.
  static const int roomCodeLength = 6;

  /// Returns `null` when [code] is a valid room code.
  static String? roomCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return 'Room code is required.';
    }
    final trimmed = code.trim().toUpperCase();
    if (trimmed.length != roomCodeLength) {
      return 'Room code must be exactly $roomCodeLength characters.';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmed)) {
      return 'Room code may only contain letters and numbers.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Room name
  // ---------------------------------------------------------------------------

  static const int maxRoomNameLength = 50;

  /// Returns `null` when [name] is a valid room name.
  static String? roomName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Room name is required.';
    }
    if (name.trim().length > maxRoomNameLength) {
      return 'Room name may not exceed $maxRoomNameLength characters.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Dice notation
  // ---------------------------------------------------------------------------

  /// Matches standard dice notation: [N]d<sides>[+/-<modifier>]
  /// Examples: 2d6, d20, 1d8+3, 3d6-1
  static final _diceNotationRegex = RegExp(
    r'^\d*[dD]\d+([+-]\d+)?$',
  );

  /// Returns `null` when [notation] is valid dice notation.
  static String? diceNotation(String? notation) {
    if (notation == null || notation.trim().isEmpty) {
      return 'Dice notation is required.';
    }
    final trimmed = notation.trim();
    if (!_diceNotationRegex.hasMatch(trimmed)) {
      return 'Invalid dice notation. Use formats like "2d6", "1d20+5", or "3d8-2".';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Display name
  // ---------------------------------------------------------------------------

  static const int maxDisplayNameLength = 30;

  /// Returns `null` when [name] is a valid display name.
  static String? displayName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Display name is required.';
    }
    if (name.trim().length > maxDisplayNameLength) {
      return 'Display name may not exceed $maxDisplayNameLength characters.';
    }
    return null;
  }
}

/// Password strength levels returned by [Validators.passwordStrength].
enum PasswordStrength {
  none,
  weak,
  fair,
  strong;

  String get label {
    switch (this) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}
