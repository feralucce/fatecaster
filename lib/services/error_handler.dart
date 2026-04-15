import 'dart:developer' as developer;
import '../exceptions/app_exceptions.dart';

/// Converts raw exceptions from Firebase or other sources into typed
/// [AppException] instances with user-friendly messages, and logs them.
class ErrorHandler {
  ErrorHandler._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Converts any exception into an [AppException].
  ///
  /// Handles:
  /// - [AppException] subclasses (passed through as-is)
  /// - Firebase Auth exceptions (`PlatformException` with Firebase codes)
  /// - Generic network / Firebase errors
  /// - Unknown errors
  static AppException handle(Object error, {StackTrace? stackTrace}) {
    developer.log(
      'ErrorHandler.handle: $error',
      name: 'fatecaster',
      error: error,
      stackTrace: stackTrace,
    );

    // Already a typed app exception — pass it through.
    if (error is AppException) return error;

    final message = error.toString();

    // Firebase Auth errors come as PlatformException or have a 'code' field.
    // We detect them by matching known Firebase error code patterns in the
    // message string (works even without importing Firebase packages here).
    final firebaseAuthCode = _extractFirebaseAuthCode(message);
    if (firebaseAuthCode != null) {
      return AuthException.fromCode(firebaseAuthCode);
    }

    final firebaseCode = _extractFirebaseCode(message);
    if (firebaseCode != null) {
      return NetworkException.fromCode(firebaseCode);
    }

    // Network-related keywords.
    final lower = message.toLowerCase();
    if (lower.contains('network') ||
        lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('no address associated') ||
        lower.contains('failed to connect')) {
      return NetworkException.offline();
    }

    if (lower.contains('timeout') || lower.contains('timed out')) {
      return NetworkException.timeout();
    }

    // Fallback: wrap in a generic AppException.
    return _UnknownException(message: message);
  }

  /// Returns a user-friendly error message for any exception.
  static String userMessage(Object error, {StackTrace? stackTrace}) {
    return handle(error, stackTrace: stackTrace).displayMessage;
  }

  /// Logs an error without converting it.
  static void log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'fatecaster',
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static final _authCodePattern = RegExp(
    r'\[firebase_auth/([a-z\-]+)\]',
    caseSensitive: false,
  );

  static final _dbCodePattern = RegExp(
    r'\[cloud_firestore/([a-z\-]+)\]|\[firebase_database/([a-z\-]+)\]',
    caseSensitive: false,
  );

  static String? _extractFirebaseAuthCode(String message) {
    final match = _authCodePattern.firstMatch(message);
    return match?.group(1);
  }

  static String? _extractFirebaseCode(String message) {
    final match = _dbCodePattern.firstMatch(message);
    return match?.group(1) ?? match?.group(2);
  }
}

/// Internal fallback exception used when no specific type can be determined.
class _UnknownException extends AppException {
  const _UnknownException({required super.message})
      : super(
          userMessage: 'An unexpected error occurred. Please try again.',
          code: 'unknown',
        );
}
