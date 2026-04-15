/// Base class for all app-level exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? userMessage;
  final String? code;

  const AppException({
    required this.message,
    this.userMessage,
    this.code,
  });

  /// Returns a message appropriate to show to the user.
  String get displayMessage => userMessage ?? message;

  @override
  String toString() => '$runtimeType($code): $message';
}

// ---------------------------------------------------------------------------
// Authentication exceptions
// ---------------------------------------------------------------------------

/// Thrown when an authentication operation fails.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.userMessage,
    super.code,
  });

  /// Create an [AuthException] from a Firebase Auth error code.
  factory AuthException.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthException(
          code: 'invalid-email',
          message: 'The email address is not valid.',
          userMessage: 'Please enter a valid email address.',
        );
      case 'user-disabled':
        return const AuthException(
          code: 'user-disabled',
          message: 'The user account has been disabled.',
          userMessage:
              'Your account has been disabled. Please contact support.',
        );
      case 'user-not-found':
        return const AuthException(
          code: 'user-not-found',
          message: 'No user found for the given email.',
          userMessage:
              'No account found with that email address. Please sign up first.',
        );
      case 'wrong-password':
        return const AuthException(
          code: 'wrong-password',
          message: 'The password is incorrect.',
          userMessage: 'Incorrect password. Please try again.',
        );
      case 'email-already-in-use':
        return const AuthException(
          code: 'email-already-in-use',
          message: 'The email is already in use by another account.',
          userMessage:
              'An account already exists with that email. Try logging in instead.',
        );
      case 'weak-password':
        return const AuthException(
          code: 'weak-password',
          message: 'The password is too weak.',
          userMessage:
              'Password is too weak. Please use at least 8 characters with letters and numbers.',
        );
      case 'operation-not-allowed':
        return const AuthException(
          code: 'operation-not-allowed',
          message: 'Email/password sign-in is disabled.',
          userMessage: 'Sign-in is currently unavailable. Please try again later.',
        );
      case 'too-many-requests':
        return const AuthException(
          code: 'too-many-requests',
          message: 'Too many requests.',
          userMessage:
              'Too many failed attempts. Please wait a moment before trying again.',
        );
      case 'network-request-failed':
        return const AuthException(
          code: 'network-request-failed',
          message: 'A network error occurred.',
          userMessage:
              'Network error. Please check your connection and try again.',
        );
      case 'requires-recent-login':
        return const AuthException(
          code: 'requires-recent-login',
          message: 'Requires recent login.',
          userMessage:
              'For security, please sign out and sign back in before making this change.',
        );
      default:
        return AuthException(
          code: code,
          message: 'An authentication error occurred: $code',
          userMessage: 'Authentication failed. Please try again.',
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Room exceptions
// ---------------------------------------------------------------------------

/// Thrown when a room operation fails.
class RoomException extends AppException {
  const RoomException({
    required super.message,
    super.userMessage,
    super.code,
  });

  factory RoomException.notFound() => const RoomException(
        code: 'room-not-found',
        message: 'The requested room was not found.',
        userMessage:
            'Room not found. Please check the code and try again.',
      );

  factory RoomException.full() => const RoomException(
        code: 'room-full',
        message: 'The room is at maximum capacity.',
        userMessage:
            'That room is full. Please try another room or create a new one.',
      );

  factory RoomException.invalidCode() => const RoomException(
        code: 'invalid-code',
        message: 'The room code is invalid.',
        userMessage:
            'Invalid room code. Room codes are 6 characters (letters and numbers).',
      );

  factory RoomException.permissionDenied() => const RoomException(
        code: 'permission-denied',
        message: 'Permission denied for this room operation.',
        userMessage:
            'You do not have permission to perform this action in the room.',
      );

  factory RoomException.alreadyInRoom() => const RoomException(
        code: 'already-in-room',
        message: 'The user is already in the room.',
        userMessage: 'You are already in this room.',
      );

  factory RoomException.ownerCannotLeave() => const RoomException(
        code: 'owner-cannot-leave',
        message: 'The room owner cannot leave without deleting the room.',
        userMessage:
            'As the room owner, leaving will delete the room for all participants. Are you sure?',
      );

  factory RoomException.deleted() => const RoomException(
        code: 'room-deleted',
        message: 'The room has been deleted.',
        userMessage:
            'This room no longer exists. The owner may have closed it.',
      );
}

// ---------------------------------------------------------------------------
// Firebase / network exceptions
// ---------------------------------------------------------------------------

/// Wraps Firebase or network-level errors with user-friendly messages.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.userMessage,
    super.code,
  });

  factory NetworkException.offline() => const NetworkException(
        code: 'offline',
        message: 'No network connection.',
        userMessage:
            'You appear to be offline. Please check your connection and try again.',
      );

  factory NetworkException.timeout() => const NetworkException(
        code: 'timeout',
        message: 'The request timed out.',
        userMessage:
            'The request took too long. Please check your connection and try again.',
      );

  factory NetworkException.permissionDenied() => const NetworkException(
        code: 'permission-denied',
        message: 'Firebase permission denied.',
        userMessage:
            'Access denied. You may need to sign in again.',
      );

  factory NetworkException.unavailable() => const NetworkException(
        code: 'unavailable',
        message: 'The service is temporarily unavailable.',
        userMessage:
            'Service temporarily unavailable. Please try again in a moment.',
      );

  /// Create from a raw Firebase error code string.
  factory NetworkException.fromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return NetworkException.permissionDenied();
      case 'unavailable':
        return NetworkException.unavailable();
      case 'deadline-exceeded':
        return NetworkException.timeout();
      case 'network-request-failed':
        return NetworkException.offline();
      default:
        return NetworkException(
          code: code,
          message: 'A network error occurred: $code',
          userMessage: 'A connection error occurred. Please try again.',
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Validation exceptions
// ---------------------------------------------------------------------------

/// Thrown when user input fails validation.
class ValidationException extends AppException {
  /// The field that failed validation (e.g. 'email', 'password').
  final String? field;

  const ValidationException({
    required super.message,
    super.userMessage,
    super.code,
    this.field,
  });

  factory ValidationException.invalidEmail() => const ValidationException(
        field: 'email',
        code: 'invalid-email',
        message: 'Email format is invalid.',
        userMessage: 'Please enter a valid email address (e.g. user@example.com).',
      );

  factory ValidationException.weakPassword() => const ValidationException(
        field: 'password',
        code: 'weak-password',
        message: 'Password does not meet strength requirements.',
        userMessage:
            'Password must be at least 8 characters and include a number.',
      );

  factory ValidationException.invalidRoomCode() => const ValidationException(
        field: 'roomCode',
        code: 'invalid-room-code',
        message: 'Room code format is invalid.',
        userMessage:
            'Room codes must be exactly 6 alphanumeric characters.',
      );

  factory ValidationException.invalidDiceNotation() =>
      const ValidationException(
        field: 'notation',
        code: 'invalid-dice-notation',
        message: 'Dice notation format is invalid.',
        userMessage:
            'Invalid dice notation. Use formats like "2d6", "1d20+5", or "3d8-2".',
      );
}
