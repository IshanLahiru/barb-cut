import '../entities/auth_user.dart';

/// Thrown when an auth operation fails (e.g. wrong password, email in use).
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Repository interface for authentication.
/// Implemented by data layer using Firebase Auth.
abstract class AuthRepository {
  /// Stream of auth state: emits current user when sign-in state changes.
  Stream<AuthUser?> get authStateChanges;

  /// Current user if signed in, null otherwise.
  AuthUser? get currentUser;

  /// Sign in with email and password. Throws [AuthException] on failure.
  Future<AuthUser?> signIn(String email, String password);

  /// Register with email and password. Throws [AuthException] on failure.
  Future<AuthUser?> signUp(String email, String password);

  /// Sign out the current user.
  Future<void> signOut();

  /// Ensure a user is authenticated (e.g. sign in anonymously if no user).
  /// Used to allow access to Firebase Storage when no explicit sign-in yet.
  Future<void> ensureAuthenticated();
}
