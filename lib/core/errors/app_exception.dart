/// Base exception class for all app errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;

  /// User-friendly message safe to display in UI
  String get userMessage => message;
}

/// Network-related errors (timeout, no internet, connection reset)
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory NetworkException.timeout() => NetworkException(
    message: 'Connection timed out. Please check your internet connection.',
    code: 'TIMEOUT',
  );

  factory NetworkException.noInternet() => NetworkException(
    message: 'No internet connection. Please check your network.',
    code: 'NO_INTERNET',
  );

  factory NetworkException.connectionError(dynamic error) => NetworkException(
    message: 'Failed to connect. Please try again.',
    code: 'CONNECTION_ERROR',
    originalError: error,
  );
}

/// Authentication-related errors (token expiry, invalid credentials)
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory AuthException.tokenExpired() => AuthException(
    message: 'Your session has expired. Please sign in again.',
    code: 'TOKEN_EXPIRED',
  );

  factory AuthException.invalidCredentials() => AuthException(
    message: 'Invalid email or password.',
    code: 'INVALID_CREDENTIALS',
  );

  factory AuthException.notAuthenticated() => AuthException(
    message: 'Please sign in to continue.',
    code: 'NOT_AUTHENTICATED',
  );

  factory AuthException.unauthorized() => AuthException(
    message: 'You do not have permission to perform this action.',
    code: 'UNAUTHORIZED',
  );
}

/// Server-side errors (5xx, API returned error)
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required String message,
    String? code,
    this.statusCode,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory ServerException.rateLimited() => ServerException(
    message: 'Too many requests. Please wait before trying again.',
    code: 'RATE_LIMIT',
    statusCode: 429,
  );

  factory ServerException.serverError(int? statusCode) => ServerException(
    message: 'Server error. Please try again later.',
    code: 'SERVER_ERROR',
    statusCode: statusCode ?? 500,
  );

  factory ServerException.badRequest(String details) => ServerException(
    message: details,
    code: 'BAD_REQUEST',
    statusCode: 400,
  );
}

/// Input validation errors (empty search, invalid input)
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory ValidationException.emptyQuery() => ValidationException(
    message: 'Search query cannot be empty.',
    code: 'EMPTY_QUERY',
  );

  factory ValidationException.invalidEmail() => ValidationException(
    message: 'Please enter a valid email address.',
    code: 'INVALID_EMAIL',
  );

  factory ValidationException.invalidInput(String field) => ValidationException(
    message: '$field is required.',
    code: 'INVALID_INPUT',
  );
}

/// Cache or local storage errors
class CacheException extends AppException {
  CacheException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory CacheException.readFailed() => CacheException(
    message: 'Failed to read cached data.',
    code: 'CACHE_READ_FAILED',
  );

  factory CacheException.writeFailed() => CacheException(
    message: 'Failed to save data.',
    code: 'CACHE_WRITE_FAILED',
  );
}

/// Unknown/unexpected errors
class UnknownException extends AppException {
  UnknownException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory UnknownException.generic(dynamic error, StackTrace stackTrace) =>
      UnknownException(
        message: 'An unexpected error occurred. Please try again.',
        code: 'UNKNOWN_ERROR',
        originalError: error,
      );
}

/// Audio playback errors (codec unsupported, source unavailable)
class AudioPlaybackException extends AppException {
  AudioPlaybackException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory AudioPlaybackException.sourceUnavailable() => AudioPlaybackException(
    message: 'Audio source is unavailable. Please try again.',
    code: 'SOURCE_UNAVAILABLE',
  );

  factory AudioPlaybackException.codecUnsupported() => AudioPlaybackException(
    message: 'Audio format not supported on this device.',
    code: 'CODEC_UNSUPPORTED',
  );

  factory AudioPlaybackException.playbackFailed(dynamic error) =>
      AudioPlaybackException(
        message: 'Playback failed. Please try again.',
        code: 'PLAYBACK_FAILED',
        originalError: error,
      );
}

/// Local storage / persistence errors (Hive read/write, database corruption)
class LocalStorageException extends AppException {
  LocalStorageException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );

  factory LocalStorageException.initFailed(dynamic error) =>
      LocalStorageException(
        message: 'Failed to initialize local storage.',
        code: 'INIT_FAILED',
        originalError: error,
      );

  factory LocalStorageException.readFailed() => LocalStorageException(
    message: 'Failed to read from local storage.',
    code: 'READ_FAILED',
  );

  factory LocalStorageException.writeFailed() => LocalStorageException(
    message: 'Failed to write to local storage.',
    code: 'WRITE_FAILED',
  );

  factory LocalStorageException.deleteFailed() => LocalStorageException(
    message: 'Failed to delete from local storage.',
    code: 'DELETE_FAILED',
  );
}
