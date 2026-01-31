/// Base exception class for internal error handling
/// 
/// Exceptions are thrown internally; Failures are returned to presentation layer
/// This separation maintains clean architecture boundaries
abstract class AppException implements Exception {
  final String message;
  
  AppException(this.message);
}

/// Thrown when server returns error response
class ServerException extends AppException {
  ServerException(super.message);
}

/// Thrown when network call fails
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Thrown when cache/local storage operation fails
class CacheException extends AppException {
  CacheException(super.message);
}

/// Thrown when authentication/authorization fails
class AuthException extends AppException {
  AuthException(super.message);
}

/// Thrown for invalid inputs
class ValidationException extends AppException {
  ValidationException(super.message);
}

/// Thrown for parsing/serialization errors
class ParseException extends AppException {
  ParseException(super.message);
}
