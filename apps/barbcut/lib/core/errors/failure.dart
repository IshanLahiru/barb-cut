/// Base failure class for error handling throughout the app
///
/// Use Either&lt;Failure, SuccessType&gt; for type-safe error handling
/// Example: Either&lt;Failure, List&lt;User&gt;&gt;
abstract class Failure {
  final String message;

  Failure(this.message);
}

/// Server-side errors (API responses, 5xx errors)
class ServerFailure extends Failure {
  ServerFailure(super.message);
}

/// Network connectivity issues
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

/// Local cache/storage errors
class CacheFailure extends Failure {
  CacheFailure(super.message);
}

/// Input validation errors
class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

/// Authentication/Authorization errors
class AuthFailure extends Failure {
  AuthFailure(super.message);
}

/// Unknown/unexpected errors
class UnknownFailure extends Failure {
  UnknownFailure([super.message = 'An unknown error occurred']);
}
